select distinct
ci.cst_gender,
ca.gen,
case
when ci.cst_gender != 'n/a' then ci.cst_gender
else coalesce(ca.gen,'n/a')
end as new_gen

from silver.crm_cust_info ci 
left join silver.erp_cust_az12 ca
on			ci.cst_key = ca.cid
left join silver.erp_loc_a101 la
on			ci.cst_key = la.cid 
 



 select * from gold.dim_customers 
 select * from gold.dim_product
 select * from gold.fact_sales

 -- Foreign Key Integrity Check
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;