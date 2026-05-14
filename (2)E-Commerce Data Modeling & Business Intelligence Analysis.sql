--=================================================================================
--PROJECT: E-Commerce Data Modeling & Business Intelligence Analysis
--AUTHOR: Abdullah Nasef
--DESCRIPTION: 
--    1. Data Architecture: Transforming flat cleaned data into a Star Schema 
--       (Fact_sales, Dim_Products, Dim_Customers).
--    2. Data Integrity: Enforcing business rules (filtering returns & non-sales).
--    3. Analytical Insights: High-level reporting on Top Products, Country 
--       Performance, VIP Customers, and Sales Seasonality.
--=================================================================================
-------------------------------------------------------------------------------
-- STEP 1: Copying the clean data to a new table
-------------------------------------------------------------------------------
--نسخ البيانات النظيفة إلى جدول جديد 
select 
	InvoiceNo_cleand as InvoiceNo_F,
	StockCode_cleand as StockCode_DP_F,
	Description_cleand as Description_DP,
	quantity_numerical as quantity_F,
	InvoiceDate_cleann as InvoiceDate_F,
	UnitPrice_numerical as UnitPrice_F,
	CustomerID_cleand as Customerid_DC_F,
	countrycleand_new as country_DC
into Ecoomerce_cleaned
from [dataEcommerce_Cl]
where 
	StockCode_cleand is not null --We don't want any sales that aren't linked to a real product.
	and Description_cleand is not null; --Exclude any sale that does not have a clear product description.
--=================================================================================
-------------------------------------------------------------------------------
-- STEP 2: DATA MODELING (STAR SCHEMA CREATION)
-------------------------------------------------------------------------------
--1 DP (Dimension Product) Create the table 
select distinct
	StockCode_DP_F,
	Description_DP
into Dim_Products
from Ecoomerce_cleaned;
--2 DC (Dimension Customer)Create the table
select distinct
	Customerid_DC_F,
	country_DC
into Dim_Customers
from Ecoomerce_cleaned;
--3 F (Fact Sales)Create the table
select 
	InvoiceNo_F,
	StockCode_DP_F,
	Customerid_DC_F,
	quantity_F,
	UnitPrice_F,
	InvoiceDate_F
into Fact_salse
from Ecoomerce_cleaned;
--=================================================================================
-------------------------------------------------------------------------------
-- STEP 4: CORE BUSINESS ANALYSIS & REPORTING
-------------------------------------------------------------------------------
-- NOTE: The following queries use JOINsfor immediate data exploration.
-- In the next stage,we will encapsulate this logic into a"View" 
-- to provide a persistent,clean,and reusable data source for Power BI.
-------------------------------------------------------------------------------.
-- Preliminary Data Integration using JOINs for exploration.
-- NOTE: This logic will later be encapsulated into a SQL VIEW for Power BI connectivity.
SELECT 
    F.InvoiceNo_F, 
    P.Description_DP,      -- Product name from the product list
    C.country_DC,          -- Customer country from the customer table
    F.quantity_F, 
    F.UnitPrice_F,
    (F.quantity_F * F.UnitPrice_F) AS TotalPrice -- Calculating the total line
FROM Fact_salse AS F
INNER JOIN Dim_Products AS P ON F.StockCode_DP_F = P.StockCode_DP_F
INNER JOIN Dim_Customers AS C ON F.Customerid_DC_F = C.Customerid_DC_F
where f.quantity_F > 0  -- Exclude sales returns (negative quantities)
	and f.UnitPrice_F> 0 -- Exclude free samples and data entry errors
ORDER BY TotalPrice DESC;
-- تحديد ال السعر الاجمالي لكل فاتورة في الجدول 
--استخدمت INNER JOIN  عشان تحدد فقط العمليات اللي فيها بيانات كاملة


--(1)Total Price تحليل عمود ال 
--1 Identifying the top 10 products
select top 15
	p.Description_DP,
	sum(f.quantity_F * f.UnitPrice_F) as Total_sales,
	sum(f.quantity_F) as Units_sold
from Fact_salse as f
inner join Dim_Products as p
		on f.StockCode_DP_F = p.StockCode_DP_F
where f.quantity_F > 0 
and f.UnitPrice_F> 0
and P.Description_DP not in (
    'DAMAGES', 'FAULTY', 'WRONGLY MARKED CARTON 22804', 
    'MAILOUT', 'POSTAGE', 'DOTCOM POSTAGE', 'CRUK Commission',
    'WEBSITE FIXED', 'FOR ONLINE RETAIL ORDERS',
	'ALLOCATE STOCK FOR DOTCOM ORDERS TA'
  )
  and P.Description_DP not like '%ADJUST%'
  and P.Description_DP not like '%STOCK%'
group by p.Description_DP
order by Total_sales desc;
--2 Select the 10 least expensive products
select top 15
	p.Description_DP,
	sum(f.quantity_F * f.UnitPrice_F) as Total_sales,
	sum(f.quantity_F) as Units_sold
from Fact_salse as f
inner join Dim_Products as p
		on f.StockCode_DP_F = p.StockCode_DP_F
where f.quantity_F > 0 
and f.UnitPrice_F> 0
and P.Description_DP not in (
    'DAMAGES', 'FAULTY', 'WRONGLY MARKED CARTON 22804', 
    'MAILOUT', 'POSTAGE', 'DOTCOM POSTAGE', 'CRUK Commission',
    'WEBSITE FIXED', 'FOR ONLINE RETAIL ORDERS',
	'ALLOCATE STOCK FOR DOTCOM ORDERS TA'
  )
  and P.Description_DP not like '%ADJUST%'
  and P.Description_DP not like '%STOCK%'
group by p.Description_DP
order by Total_sales asc;
--3 GEOGRAPHIC SALES PERFORMANCE
-- Ranks countries by revenue and total order volume
select 
	c.country_DC as country ,
	sum(f.quantity_F * f.UnitPrice_F) as Total_sales,
	count(distinct f.InvoiceNo_F) as total_orders
from Fact_salse as f
inner join Dim_Customers as c
		on f.Customerid_DC_F = c.Customerid_DC_F
inner join Dim_Products as p
		on f.StockCode_DP_F = p.StockCode_DP_F
where f.quantity_F > 0 
and f.UnitPrice_F> 0
--The following conditions are excluded to prevent the supply of fictitious figures to the countries whose shares are held in reserve.
  and P.Description_DP not in (
    'DAMAGES', 'FAULTY', 'WRONGLY MARKED CARTON 22804', 
    'MAILOUT', 'POSTAGE', 'DOTCOM POSTAGE', 'CRUK Commission',
    'WEBSITE FIXED', 'FOR ONLINE RETAIL ORDERS',
	'ALLOCATE STOCK FOR DOTCOM ORDERS TA'
  )
  and P.Description_DP not like '%ADJUST%'
  and P.Description_DP not like '%STOCK%'

group by c.country_DC
order by Total_sales desc;


--4 VIP CUSTOMER ANALYSIS (TOP 30)
select top 30
	f.Customerid_DC_F,
	c.country_DC,
	sum(f.quantity_F * f.UnitPrice_F) as custemer_spend
from Fact_salse as f
inner join Dim_Customers as c
		on f.Customerid_DC_F=c.Customerid_DC_F
inner join Dim_Products as p
		on f.StockCode_DP_F = p.StockCode_DP_F
where f.quantity_F > 0 
and f.UnitPrice_F> 0
and P.Description_DP not in (
    'DAMAGES', 'FAULTY', 'WRONGLY MARKED CARTON 22804', 
    'MAILOUT', 'POSTAGE', 'DOTCOM POSTAGE', 'CRUK Commission',
    'WEBSITE FIXED', 'FOR ONLINE RETAIL ORDERS',
	'ALLOCATE STOCK FOR DOTCOM ORDERS TA'
  )
  and P.Description_DP not like '%ADJUST%'
  and P.Description_DP not like '%STOCK%'
group by f.Customerid_DC_F ,c.country_DC
order by custemer_spend desc;

--5 SALES SEASONALITY & TREND ANALYSIS
-- Monthly revenue trends including day count to investigate data anomalies (e.g., Dec 2011)
SELECT
select 
	year(f.InvoiceDate_F) as sales_year,
	month(f.InvoiceDate_F) as sales_month,
	-- I added the number of days to find out the reason for the decrease in sales in December 2011.
	count(distinct day(f.InvoiceDate_F)) as dayys_count, 
	sum(f.quantity_F * f.UnitPrice_F) as monthly_sales
from Fact_salse as f
inner join Dim_Products as p
		on f.StockCode_DP_F = p.StockCode_DP_F
where f.quantity_F > 0 
and f.UnitPrice_F> 0
and P.Description_DP not in (
    'DAMAGES', 'FAULTY', 'WRONGLY MARKED CARTON 22804', 
    'MAILOUT', 'POSTAGE', 'DOTCOM POSTAGE', 'CRUK Commission',
    'WEBSITE FIXED', 'FOR ONLINE RETAIL ORDERS',
	'ALLOCATE STOCK FOR DOTCOM ORDERS TA'
  )
  and P.Description_DP not like '%ADJUST%'
  and P.Description_DP not like '%STOCK%'
group by year(InvoiceDate_F), month(f.InvoiceDate_F)
order by year(InvoiceDate_F), month(f.InvoiceDate_F);
