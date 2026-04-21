--CUSTOMERS TABLE DETAILS

create view gold.dim_customers as
select
ROW_NUMBER() over (order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_material_status as marital_status,
case
when ci.cst_gender != 'n/a' then ci.cst_gender
else coalesce(ca.gen,'n/a')
end as gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date

from silver.crm_cust_info ci 
left join silver.erp_cust_az12 ca
on			ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on			ci.cst_key = la.cid 



--PRODUCTS TABLE DETIALS 
create view gold.dim_product as 
select 
ROW_NUMBER() over (order by pi.prd_start_dt ,pi.product_key) as product_key,
pi.prd_id as product_id,
pi.product_key as product_number,
pi.prd_nm as product_name,
pi.prd_cost as cost,
pi.category_id as category_id,
po.cat as category,
po.subcat as sub_category,
pi.prd_line as product_line,
po.maintanence ,
pi.prd_start_dt as start_date
from silver.crm_prd_info pi
left join silver.erp_px_cat_g1v2 po
on pi.category_id=po.id 
where prd_end_dt is null

--sales table 
create view gold.fact_sales as
select 
sls_ord_num as order_number,
pr.product_key,
cr.customer_key,
sls_order_dt as order_date,
sls_ship_dt as shipping_date,
sls_due_dt as due_date,
sls_sales as sales_amount ,
sls_quantity as quantity,
sls_price as price
from silver.crm_sales_details sd
left join gold.dim_product pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cr
on sd.sls_cust_id = cr.customer_id

