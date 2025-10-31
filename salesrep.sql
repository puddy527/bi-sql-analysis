SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;


#prepare backup 
-- Step 1: View original table
SELECT * FROM sales_data;
CREATE TABLE sales2 LIKE sales_data ;
SELECT * FROM sales2;
INSERT INTO sales2 SELECT * FROM sales_data;
SELECT * FROM sales2;


#change type for calculation
ALTER TABLE sales2
CHANGE `Unit_Cost` Unit_Cost float;
ALTER TABLE sales2
CHANGE `Unit_Price` Unit_Price float;
ALTER TABLE sales2
CHANGE `Discount` Discount float;

#profit/total sales no tax
ALTER TABLE sales2
Add COLUMN Profit float;

ALTER TABLE sales2
Add COLUMN Total_Sales_taxless float;

UPDATE sales2
SET Total_Sales_taxless = Quantity_Sold * Unit_Price;

UPDATE sales2
SET Profit = Quantity_Sold * (Unit_Price*(1-Discount)-Unit_Cost);

#get month
ALTER TABLE sales2
ADD Sale_Month text;
  
#adding month
UPDATE sales2
  set Sale_Month= CASE
    WHEN MONTH(Sale_Date) = 1 THEN 'January'
    WHEN MONTH(Sale_Date) = 2 THEN 'February'
    WHEN MONTH(Sale_Date) = 3 THEN 'March'
    WHEN MONTH(Sale_Date) = 4 THEN 'April'
    WHEN MONTH(Sale_Date) = 5 THEN 'May'
    WHEN MONTH(Sale_Date) = 6 THEN 'June'
    WHEN MONTH(Sale_Date) = 7 THEN 'July'
    WHEN MONTH(Sale_Date) = 8 THEN 'August'
    WHEN MONTH(Sale_Date) = 9 THEN 'September'
    WHEN MONTH(Sale_Date) = 10 THEN 'October'
    WHEN MONTH(Sale_Date) = 11 THEN 'November'
    WHEN MONTH(Sale_Date) = 12 THEN 'December'
    ELSE null
  END;
  
  #month arrange
CREATE TABLE monthnocounter AS
Select
  Sale_Month,Profit,
  CASE Sale_Month
    WHEN 'January' THEN 1
    WHEN 'February' THEN 2
    WHEN 'March' THEN 3
    WHEN 'April' THEN 4
    WHEN 'May' THEN 5
    WHEN 'June' THEN 6
    WHEN 'July' THEN 7
    WHEN 'August' THEN 8
    WHEN 'September' THEN 9
    WHEN 'October' THEN 10
    WHEN 'November' THEN 11
    WHEN 'December' THEN 12
    ELSE NULL
  END AS MonthNumber
FROM sales2;
select * from monthnocounter;

  #discount range 
CREATE TABLE Discount_Range AS
SELECT
  Discount,
  CASE 
    WHEN ROUND(Discount, 2) BETWEEN 0 AND 0.10 THEN 'Low Discount'
    WHEN ROUND(Discount, 2) BETWEEN 0.11 AND 0.20 THEN 'Medium Discount'
    WHEN ROUND(Discount, 2) >= 0.21 THEN 'High Discount'
    ELSE 'Other'
  END AS discountrange
FROM sales2;
select * from Discount_Range;

#avgtotalsales
Create Table  sales_rep_avg as
select Sales_Rep,avg(Total_Sales_Taxless) as avg_sales from sales2 group by Sales_Rep;


#returning Customers
Create Table  returncust as
SELECT 
	Sales_Rep,
  COUNT(CASE WHEN Customer_Type = 'Returning' THEN 1 END) * 1.0 / COUNT(Customer_Type) AS return_ratio
FROM sales2
GROUP BY Sales_Rep;
select * from returncust;

#expensive
CREATE TABLE expensive AS
SELECT 
  Product_Category,
  sum(Unit_price) / sum(Quantity_Sold) AS avg_expprice
FROM sales2
GROUP BY Product_Category;
select * from expensive;

#eff ratio
CREATE TABLE eff AS
SELECT 
  Region,
  sum(Profit) / sum(Total_sales_taxless) AS effratio
FROM sales2
GROUP BY Region;
select * from eff;