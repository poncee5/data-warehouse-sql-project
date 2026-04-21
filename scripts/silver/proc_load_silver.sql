create or alter procedure silver.load_silver as 
begin

PRINT '---------------------------------'
PRINT 'Loading silver layer:'
PRINT '---------------------------------'

DECLARE 
    @start_time DATETIME,
    @end_time DATETIME,
    @batch_start_time DATETIME,
    @batch_end_time DATETIME;

BEGIN TRY

    PRINT '---------------------------------'
    PRINT 'Loading crm tables:'
    PRINT '---------------------------------'


    -- SILVER.CRM_CUST_INFO
    SET @batch_start_time = GETDATE();
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.crm_cust_info'
    TRUNCATE TABLE silver.crm_cust_info;

    PRINT '>>>inserting data info:silver.crm_cust_info'

    INSERT INTO silver.crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gender,
        cst_create_date
    )
    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),

        CASE
            WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END,

        cst_create_date

    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY cst_id 
                   ORDER BY cst_create_date DESC
               ) AS repeated_ranking
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t

    WHERE repeated_ranking = 1;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    -- SILVER.CRM_PRD_INFO
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.crm_prd_info'
    TRUNCATE TABLE silver.crm_prd_info;

    PRINT '>>>inserting data info:silver.crm_prd_info'

    INSERT INTO silver.crm_prd_info
    (
        prd_id,
        category_id,
        product_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS category_id,
        SUBSTRING(prd_key, 7, LEN(prd_key)) AS product_key,
        prd_nm,
        ISNULL(prd_cost, 0),

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            ELSE 'n/a'
        END,

        prd_start_dt,

        CAST(
            DATEADD(
                DAY, -1,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                )
            ) AS DATE
        )

    FROM bronze.crm_prd_info;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    -- SILVER.CRM_SALES_DETAILS
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.crm_sales_details'
    TRUNCATE TABLE silver.crm_sales_details;

    PRINT '>>>inserting data info:silver.crm_sales_details'

    ;WITH cleaned AS (
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            TRY_CAST(sls_sales AS FLOAT) AS raw_sales,
            TRY_CAST(sls_quantity AS FLOAT) AS raw_quantity,
            TRY_CAST(sls_price AS FLOAT) AS raw_price,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt
        FROM bronze.crm_sales_details
    ),

    fixed AS (
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE 
                WHEN sls_order_dt = 0 
                  OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8 
                THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR), 112)
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt = 0 
                  OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 
                THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR), 112)
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt = 0 
                  OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8 
                THEN NULL
                ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR), 112)
            END AS sls_due_dt,

            raw_quantity AS sls_quantity,

            CASE 
                WHEN raw_price IS NULL OR raw_price < 0
                THEN raw_sales / NULLIF(raw_quantity, 0)
                ELSE raw_price
            END AS sls_price,

            CASE
                WHEN raw_sales IS NULL 
                  OR raw_quantity * raw_price != raw_sales
                THEN raw_quantity *
                     (
                        CASE 
                            WHEN raw_price IS NULL OR raw_price < 0 
                            THEN raw_sales / NULLIF(raw_quantity, 0)
                            ELSE raw_price 
                        END
                     )
                ELSE raw_sales
            END AS sls_sales

        FROM cleaned
    )

    INSERT INTO silver.crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_quantity,
        sls_price,
        sls_sales
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_quantity,
        sls_price,
        sls_sales
    FROM fixed;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    -- SILVER.ERP_CUST_AZ12
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.erp_cust_az12'
    TRUNCATE TABLE silver.erp_cust_az12;

    PRINT '>>>inserting data info:silver.erp_cust_az12'

    INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
    SELECT 
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END,

        CASE 
            WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END,

        CASE 
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'n/a'
        END

    FROM bronze.erp_cust_az12;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    -- SILVER.ERP_LOC_A101
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.erp_loc_a101'
    TRUNCATE TABLE silver.erp_loc_a101;

    PRINT '>>>inserting data info:silver.erp_loc_a101'

    INSERT INTO silver.erp_loc_a101 (cid, cntry)
    SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE 
            WHEN cntry = 'DE' THEN 'Germany'
            WHEN cntry IN ('US', 'USA') THEN 'United States'
            WHEN cntry IS NULL OR cntry = ' ' THEN 'n/a'
            ELSE cntry
        END

    FROM bronze.erp_loc_a101;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    -- SILVER.ERP_PX_CAT_G1V2
    SET @start_time = GETDATE();

    PRINT '>>>truncating table:silver.erp_px_cat_g1v2'
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    PRINT '>>>inserting data info:silver.erp_px_cat_g1v2'

    INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintanence)
    SELECT 
        id,
        cat,
        subcat,
        maintanence
    FROM bronze.erp_px_cat_g1v2;


    SET @end_time = GETDATE();

    PRINT '>>load duration:' 
        + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) 
        + ' seconds';

    PRINT '------------------------------'


    SET @batch_end_time = GETDATE();

    PRINT '-------------------------------------'
    PRINT 'LOADING BRONZE LAYER IS COMPLETED'
    PRINT 'Total load duration:' 
        + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
        + ' seconds';


END TRY

BEGIN CATCH

    PRINT '***************************************'
    PRINT 'ERROR OCCURED WHILE LOADING BRONZE LAYER'
    PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE()
    PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR)
    PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR)
    PRINT '***************************************'

END CATCH
end

exec silver.load_silver 