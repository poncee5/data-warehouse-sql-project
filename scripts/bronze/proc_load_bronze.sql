CREATE OR ALTER procedure bronze.load_bronze as 
begin
	
	declare @start_time datetime , @end_time datetime ,@batch_start_time datetime ,@batch_end_time datetime; 
	Begin Try
		print '------------------------------------------'
		print'Loading bronze layer.....'
		print '------------------------------------------'


		print '------------------------------------------'
		print 'loading CRM Tables:'
		set @batch_start_time = GETDATE();
		set @start_time = GETDATE();

		print '>>truncating table crm_cust_info'
		print '>>Loading table crm_cust_info'


			truncate table bronze.crm_cust_info

			bulk insert bronze.crm_cust_info
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);


			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'


			-----------------------------------------------------------------
			set @start_time = GETDATE();
			print '>>truncating table crm_prd_info'
			print '>>Loading table crm_prd_info'
			truncate table bronze.crm_prd_info

			bulk insert bronze.crm_prd_info
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);


			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'

			----------------------------------------------------------------
			set @start_time = GETDATE();
			print '>>truncating table crm_sales_details'
			print '>>Loading table crm_sales_details'
			truncate table bronze.crm_sales_details

			bulk insert bronze.crm_sales_details
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);


			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'

			---------------------------------------------------------------
			print'Loading ERP tables:'
			---------------------------------------------------------------
			set @start_time = GETDATE();
			print '>>truncating table erp_cust_az12'
			print '>>Loading table erp_cust_az12'
			truncate table bronze.erp_cust_az12


			bulk insert bronze.erp_cust_az12
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);

			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'


			---------------------------------------------------
			set @start_time = GETDATE();
			print '>>truncating table erp_loc_a101'
			print '>>Loading table erp_cust_a101'
			truncate table bronze.erp_loc_a101

			bulk insert bronze.erp_loc_a101
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);

			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'


			---------------------------------------------------
			set @start_time = GETDATE();
			print '>>truncating table erp_px_cat_g1v2'
			print '>>Loading table erp_px_cat_g1v2'
			truncate table bronze.erp_px_cat_g1v2

			bulk insert bronze.erp_px_cat_g1v2
			from 'C:\Users\Micro Systems\Documents\DataAnalysisCourse\DataWareHOuseProject\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
			with (
			firstrow =2 ,
			fieldterminator = ',',
			tablock);

			set @end_time = GETDATE();
			print '>>load duration:' + cast (datediff(second, @start_time , @end_time) as nvarchar) + 'seconds';
			print'------------------------------'

			set @batch_end_time = GETDATE();
			print'-------------------------------------'
			print'LOADING BRONZE LAYER IS COMPLETED'
			print'Total load duration:' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar )+ 'seconds';

	End Try
	Begin Catch 
		print'***************************************'
		print 'ERROR OCCURED WHILE LOADING BRONZE LAYER'
		print 'ERROR MESSAGE' + ERROR_MESSAGE();
		print 'ERROR MESSAGE' + CAST(ERROR_NUMBER() AS NVARCHAR);
		print 'ERROR MESSAGE' + CAST(ERROR_STATE() AS NVARCHAR);
		print'***************************************'

	End Catch
end


