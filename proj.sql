drop database if exists DataWarehouse;

create database if not exists DataWarehouse;

use DataWarehouse;

create schema bronze;
create schema silver;
create schema gold;

select 'hello';