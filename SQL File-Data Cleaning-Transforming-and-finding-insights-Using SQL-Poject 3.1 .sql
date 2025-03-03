-- Creating Database
CREATE DATABASE customer_reviews_project;
use customer_reviews_project;

-- Inserting table from CSV file

-- Checking imported table and its data
SELECT * FROM customer_reviews;

-- Data Cleaning

-- Finding Duplicates
with cte_for_checking_duplicates as (
	select *, row_number() over(PARTITION BY Date, ID, Name, Region, Rating, Product, Quantity, `Price Per Unit`) as `Row Number`
	from customer_reviews
)
select * from cte_for_checking_duplicates
where `Row Number` > 1;

-- Deleting Duplicates
/*
To delete duplicates we have to create new table with all values from 'customer_reviews' including 'Row Number' column
So we will create new table named as customer_reviews_2 with all columns from 'customer_reviews' including 'Row Number' column.
*/

CREATE TABLE `customer_reviews_2` (
  `Date` text,
  `ID` int DEFAULT NULL,
  `Name` text,
  `Region` text,
  `Rating` text,
  `Product` text,
  `Quantity` int DEFAULT NULL,
  `Price Per Unit` text,
  `Row Number` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * from customer_reviews_2;

-- Inserting values in 'customer_reviews_2' table from 'customer_reviews' table with values for'Row Number' column

INSERT into customer_reviews_2
select *, row_number() over(PARTITION BY Date, ID, Name, Region, Rating, Product, Quantity, `Price Per Unit`) as `Row Number`
	from customer_reviews;

SELECT * from customer_reviews_2;

-- Checking duplicates agian in new table 'customer_reviews_2'
select * from customer_reviews_2
where `Row Number` > 1;

-- Total records before deleting
select count(*) as `Total Records` from customer_reviews_2;

-- Now deleting duplicates
DELETE from customer_reviews_2
where `Row Number` > 1;

-- Total records after deleting of duplicates
select count(*) as `Total Records` from customer_reviews_2;

-- Checking and Correcting important misspelled words
SELECT * from customer_reviews_2;
SELECT distinct(Rating) from customer_reviews_2;

update customer_reviews_2
set Rating = 'Excellent'
where Rating = 'Excelent';

SELECT distinct(Rating) from customer_reviews_2;

-- Checking and Removing space which present before  and after name 
select Name, trim(Name)
from customer_reviews_2;

-- see this name has space after name. 'John Smith   ' so after trim it will become 'John Smith'
-- now updating values using trim
Update customer_reviews_2 
set Name = trim(Name);

-- some name has space between first name and last name
select Name from customer_reviews_2;
/* 
like this name has space more than one betwween first name and last name 'Peter   Parker'.
to remove space more than one between first name and last name we have to use following query multiple times until we get all
spaces removed .
*/
update customer_reviews_2
set Name = replace(Name, '  ', ' ')
where Name like '%  %';
-- now here we can see 3 rows affected and 3 changed,  we will run this query again and again till it shows 0 rows affected.
-- now its done. 0 rows affected means no more name present which has more than one space between it.
select Name from  customer_reviews_2;
-- we can see result 'Peter Parker'

-- Cheking region column for accuracy.
select distinct(Region) from customer_reviews_2;
-- so here are some empty values and incorrect values like 'Asgard'
-- so we will replace those with 'NA' - Not Available
UPDATE customer_reviews_2 
set Region = 'NA'
where Region = 'Asgard' or Region = '';

select distinct(Region) from customer_reviews_2;

-- replacing 'inf' value to 0 from 'Price Per Unit' column
SELECT * from customer_reviews_2;

UPDATE customer_reviews_2 
set `Price Per Unit` = 0
where `Price Per Unit` = 'inf';

-- Correcting data types of columns
DESCRIBE customer_reviews_2;

-- we can see 'Date' column has 'text' data type which is incorrect.
SELECT * from customer_reviews_2;

-- we have to remove 00:00 time.
update customer_reviews_2
set Date = replace(Date, '00:00', '')
where Date like '%00:00%';

SELECT * from customer_reviews_2;

-- trimming any space from date column
update customer_reviews_2
set Date = trim(Date);

SELECT * from customer_reviews_2;

-- Now correcting inserted date format to change data type of Date column
-- here we can see the correct format for date.
select Date, str_to_date(Date, '%d-%m-%y') as `Correct Date format` from customer_reviews_2;

-- correcting date format

update customer_reviews_2
set `Date` = str_to_date(`Date`, '%d-%m-%Y')
WHERE str_to_date(`Date`, '%d-%m-%Y') is not null;

SELECT * from customer_reviews_2;

-- Now changing data type of 'Date' column
alter table customer_reviews_2
modify COLUMN Date DATE;

DESCRIBE customer_reviews_2;

-- now to change data type of 'Price Per Unit' to int we have to remove '$' Sign
update customer_reviews_2
set `Price Per Unit` = replace(`Price Per Unit`, '$', '')
where `Price Per Unit` like '%$%';

SELECT * from customer_reviews_2;

-- triming spaces of values from 'Price Per Unit' column.
update customer_reviews_2
set `Price Per Unit` = trim(`Price Per Unit`);

SELECT * from customer_reviews_2;

-- Now changing data type of Column 'Price per Unit' to int
alter table customer_reviews_2
modify COLUMN `Price Per Unit` int;

DESCRIBE customer_reviews_2;

-- declearing 'ID' as a Primary Key and not null
alter table customer_reviews_2
add Primary key (ID);

DESCRIBE customer_reviews_2;

-- removing 'Row Number Column' because not necessary now
alter table customer_reviews_2
drop column `Row Number`;

SELECT * from customer_reviews_2;

-- Finding some insights 

-- Total Quantity by Region
select Region, sum(Quantity) as `Total Quantity` from customer_reviews_2
GROUP BY Region;

-- Total Revenue by Region
select Region, sum(Quantity * `Price Per Unit`) as `Total Revenue` from customer_reviews_2
GROUP BY Region;

-- Total counts of Rating
select Rating, count(Rating) as `Total Count` from customer_reviews_2
GROUP BY Rating;

-- Top Product by Quantity
select Product, sum(Quantity) as `Total Quantity`
from customer_reviews_2
group by Product order by `Total Quantity` desc limit 1;

-- Top Person by Total Revenue
select Name, sum(Quantity * `Price Per Unit`) as `Total Revenue`
from customer_reviews_2
group by Name order by `Total Revenue` desc limit 1;

-- Yearly trend in sale
select year(Date) as Year, sum(Quantity) as `Total Quantity`
from customer_reviews_2
GROUP BY Year;

/*
Date: 3 March 2025
Name: Sanket Thange
*/
