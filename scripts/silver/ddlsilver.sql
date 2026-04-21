-- SILVER.CRM_CUST_INFO
IF OBJECT_ID ('silver.crm_cust_info' ,'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;

CREATE TABLE silver.crm_cust_info(
    cst_id NVARCHAR(50),
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gender NVARCHAR(50),
    cst_create_date NVARCHAR(50),
    dwh_create_date datetime2 default getdate()
);


-- SILVER.CRM_PRD_INFO
IF OBJECT_ID ('silver.crm_prd_info' ,'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info(
    prd_id NVARCHAR(50),
    category_id NVARCHAR(50),   -- derived from prd_key
    product_key NVARCHAR(50),   -- derived from prd_key
    prd_nm NVARCHAR(50),
    prd_cost NVARCHAR(50),
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date datetime2 default getdate()
);


-- SILVER.CRM_SALES_DETAILS
IF OBJECT_ID ('silver.crm_sales_details' ,'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;

CREATE TABLE silver.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id NVARCHAR(50),
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales FLOAT,
    sls_quantity FLOAT,
    sls_price FLOAT,
    dwh_create_date datetime2 default getdate()
);


-- SILVER.ERP_CUST_AZ12
IF OBJECT_ID ('silver.erp_cust_az12' ,'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12(
    cid NVARCHAR(50),
    bdate NVARCHAR(50),
    gen NVARCHAR(50),
    dwh_create_date datetime2 default getdate()
);


-- SILVER.ERP_LOC_A101
IF OBJECT_ID ('silver.erp_loc_a101' ,'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date datetime2 default getdate()
);


-- SILVER.ERP_PX_CAT_G1V2
IF OBJECT_ID ('silver.erp_px_cat_g1v2' ,'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintanence NVARCHAR(50),
    dwh_create_date datetime2 default getdate()
);
