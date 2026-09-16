 -- select * from silver.crm_cust_info;
 
 -- joining tables having customer info
 -- give meaningful names to the columns 
 -- this is a dimesion table not a fact table as it has no details about events and transactions
 -- we need pm key for this, 
 -- surrogate key- system generated unique identifier assigned to eachrecord in a table
 -- can use ddl based generation or row_number like wf to generate this
 
 create view gold.dim_customers as
 select
 row_number() over (order by cst_id) as customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
case when ci.cst_gndr!='n/a' then ci.cst_gndr
  else coalesce(ca.gen,'n/a')
end as gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid;

-- have multiple gender cols, checks whether both cols hv same for all values
-- the missing info in one maybe in other, null might be there, nulls necaus eof no match
-- so ask the data experts about it which table is master crm or erp because1 table has male and other has female for the same record
-- if crm is master then retain values form it
select distinct ci.cst_gndr,ca.gen,
case when ci.cst_gndr!='n/a' then ci.cst_gndr
  else coalesce(ca.gen,'n/a')
end as new_gen
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid;

-- might end up getting duplicate after joining tables check for those
select cst_id,count(*) from(
select
ci.cst_id,ci.cst_key,ci.cst_firstname,ci.cst_lastname,ci.cst_marital_status,ci.cst_gndr,ci.cst_create_date,
ca.bdate,ca.gen,
la.cntry
from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ci.cst_key=ca.cid
left join silver.erp_loc_a101 la
on ci.cst_key=la.cid)t
group by cst_id
having count(*) >1;

select * from gold.dim_customers;

-- ------------------------------------------------------------
-- Joining product info tables
-- ------------------------------------------------------------

-- dimesion table
-- it contains historical data as well if we do not want to retain it, we can just keep the records having end date as null hwich says it as current data
-- check for duplicate prd_key
-- select prd_key, count(*) from(
create view gold.dim_products as
select
row_number() over (order by pn.prd_start_dt, pn.prd_key) as product_key,
pn.prd_id as product_id,
pn.prd_key as product_number,
pn.prd_nm as product_name,
pn.cat_id as category_id,
pc.cat as category,
pc.subcat as subcategory,
pc.maintenance,
pn.prd_cost as cost,
pn.prd_line as product_line,
pn.prd_start_dt as start_date
-- pn.prd_end_dt
from silver.crm_prd_info pn
left join silver.erp_px_cat_g1v2 pc
on pn.cat_id=pc.id
where pn.prd_end_dt is null;
-- t group by prd_key having count(*)>1;

-- ------------------------------------------------------------
-- Joining sales info table
-- ------------------------------------------------------------

-- it has both prd_key and cust_id and has measures, so it is a fact table
-- fact is connecting multiple dimensions, we hv to present this fcat the surrogate keys that come from the dimensions table
-- so replca ethis prd_key and cust_id with surrogate keys we created in gold layers..this is called DATA LOOKUP
create view gold.fact_sales as
select
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key=pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id=cu.customer_id;

-- foreign key integrity
-- chekcing if anything is mismatching
select * from
gold.fact_sales f
left join gold.dim_products p on p.product_key=f.product_key
left join gold.dim_customers c on c.customer_key = f.customer_key
where p.product_key is null or c.customer_key is null;
