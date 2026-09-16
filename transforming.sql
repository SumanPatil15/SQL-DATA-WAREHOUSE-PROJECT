DELIMITER $$
DROP PROCEDURE IF EXISTS silver.load_silver $$
create procedure silver.load_silver ()
begin
	SELECT '>> Truncating Table: silver.crm_cust_info' AS message;
	truncate table silver.crm_cust_info;
	SELECT '>> Inserting data into: silver.crm_cust_info' AS message;
	insert into silver.crm_cust_info(
	cst_id, cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
	select cst_id, cst_key, trim(cst_firstname) as cst_firstname, trim(cst_lastname) as cst_lastname,
    case when upper(trim(cst_marital_status))='S' then 'Single'
		 when upper(trim(cst_marital_status))='M' then 'Married'
		 else 'n/a'
	end cst_marital_status,
	case when upper(trim(cst_gndr))='F' then 'Female'
		 when upper(trim(cst_gndr))='M' then 'Male'
		 else 'n/a'
	end cst_gndr,
	cst_create_date 
	from(
	select *,
	row_number() over (partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	where cst_id is not null
	and cast(cst_create_date as char) <> '0000-00-00'
	)t where flag_last=1;


	-- DROP TABLE IF EXISTS silver.crm_prd_info;
	-- CREATE TABLE silver.crm_prd_info (
	   --  prd_id INT,
		-- cat_id VARCHAR(50),
		-- prd_key VARCHAR(50),
		-- prd_nm VARCHAR(50),
		-- prd_cost INT,
		-- prd_line VARCHAR(50),
		-- prd_start_dt DATE,
		-- prd_end_dt DATE,
		-- dwh_create_date DATETIME DEFAULT NOW()
	-- );

	SELECT '>> Truncating Table: silver.crm_prd_info' AS message;
	truncate table silver.crm_prd_info;
	SELECT '>> Inserting data into: silver.crm_prd_info' AS message;
	insert into silver.crm_prd_info(
	prd_id, cat_id,prd_key, prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
	select 
	prd_id,
	replace(substring(prd_key,1,5),'-','_') as cat_id,
	substring(prd_key,7,length(prd_key)) as prd_key,
	prd_nm,
	ifnull(prd_cost,0) as prd_cost,
	case when upper(trim(prd_line))='M' then 'Mountain'
		 when upper(trim(prd_line))='R' then 'Road'
		 when upper(trim(prd_line))='S' then 'Other Sales'
		 when upper(trim(prd_line))='T' then 'Touring'
		 else 'n/a'
	end as prd_line,
	cast(prd_start_dt as date) as prd_start_dt,
	cast(date_sub(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt), interval 1 day) as date) as prd_end_dt
	from bronze.crm_prd_info;

	-- CREATE TABLE silver.crm_sales_details (
	   -- sls_ord_num VARCHAR(50),
		-- sls_prd_key VARCHAR(50),
		-- sls_cust_id INT,
		-- sls_order_dt date,
		-- sls_ship_dt date,
		-- sls_due_dt date,
		-- sls_sales int,
		-- sls_quantity INT,
		-- sls_price INT,
		-- dwh_create_date datetime default now()

	-- );

	SELECT '>> Truncating Table: silver.crm_sales_details' AS message;
	truncate table silver.crm_sales_details;
	SELECT '>> Inserting data into: silver.crm_sales_details' AS message;
	insert into silver.crm_sales_details(
	sls_ord_num ,
		sls_prd_key ,
		sls_cust_id ,
		sls_order_dt ,
		sls_ship_dt ,
		sls_due_dt ,
		sls_sales,
		sls_quantity ,
		sls_price 
	)
	select 
	sls_ord_num ,
		sls_prd_key,
		sls_cust_id ,
		case when sls_order_dt =0 or length(sls_order_dt)!=8 then null
			 else cast(cast(sls_order_dt as char) as date)
		end as sls_order_dt,
		case when sls_ship_dt =0 or length(sls_ship_dt)!=8 then null
			 else cast(cast(sls_ship_dt as char) as date)
		end as sls_ship_dt,
		case when sls_due_dt =0 or length(sls_due_dt)!=8 then null
			 else cast(cast(sls_due_dt as char) as date)
		end as sls_due_dt,
		case when sls_quantity is null or sls_quantity <=0 or sls_sales!=sls_quantity*abs(sls_price)
		 then sls_quantity * abs(sls_quantity)
		 else sls_sales
	end as sls_sales,
	 sls_quantity,
	case when sls_price is null or sls_price <=0 
		 then sls_quantity / nullif(sls_quantity,0)
		 else sls_price
	end as sls_price
	from bronze.crm_sales_details;

	SELECT '>> Truncating Table: silver.erp_cust_az12' AS message;
	truncate table silver.erp_cust_az12;
	SELECT '>> Inserting data into: silver.erp_cust_az12' AS message;
	insert into silver.erp_cust_az12(cid,bdate,gen)
	select 
	case when cid like 'NAS%' then substring(cid, 4, length(cid))
		 else cid
	end as cid,
	case when bdate>now() then null
		 else bdate
	end as bdate,
	case when upper(trim(replace(gen,'\r',' '))) IN ('F', 'FEMALE') then 'Female'
		 when upper(trim(replace(gen,'\r',' '))) IN ('M', 'MALE') then 'Male'
		 else 'n/a'
	end as gen
	from bronze.erp_cust_az12;

	SELECT '>> Truncating Table: silver.erp_loc_a101' AS message;
	truncate table silver.erp_loc_a101;
	SELECT '>> Inserting data into: silver.erp_loc_a101' AS message;
	insert into silver.erp_loc_a101(cid,cntry)
	select
	replace(cid,'-','') cid,
	case when trim(replace(cntry,'\r','')) ='DE' then 'Germany'
		 when trim(replace(cntry,'\r','')) in ('US','USA') then 'United States'
		 when trim(replace(cntry,'\r',''))='' or cntry is null then 'n/a'
		 else trim(cntry)
	end cntry
	from bronze.erp_loc_a101;

	SELECT '>> Truncating Table: silver.erp_px_cat_g1v2' AS message;
	truncate table silver.erp_px_cat_g1v2;
	SELECT '>> Inserting data into: silver.erp_px_cat_g1v2' AS message;
	insert into silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
	select
	id,cat,subcat,TRIM(REPLACE(maintenance, '\r', '')) AS maintenance
	from bronze.erp_px_cat_g1v2;
end $$
DELIMITER ;

CALL silver.load_silver();


-- truncate before inserting data




