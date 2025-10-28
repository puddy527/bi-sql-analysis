SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;

#prepare backup 
-- Step 1: View original table
SELECT * FROM retail_store_sales;
CREATE TABLE retail2 LIKE retail_store_sales ;
SELECT * FROM retail2;
INSERT INTO retail2 SELECT * FROM retail_store_sales;
SELECT * FROM retail2;


#changing titles for ease
ALTER TABLE retail2
CHANGE `Transaction id` Transaction_ID text;
ALTER TABLE retail2
CHANGE `Customer id` Customer_ID text;
ALTER TABLE retail2
CHANGE `Price Per Unit` Price_Per_Unit float;
ALTER TABLE retail2
CHANGE `Quantity` Quantity float;
ALTER TABLE retail2
CHANGE `Total Spent` Total_Spent float;
ALTER TABLE retail2
CHANGE `Payment Method` Payment_Method text;
ALTER TABLE retail2
CHANGE `Transaction Date` Transaction_Date text;
ALTER TABLE retail2
CHANGE `Discount Applied` Discount_Applied text;

#fill blanks (only discount Applied)
UPDATE retail2
	set Discount_Applied= CASE
		WHEN Discount_Applied='' then 'Not Recorded'
	    ELSE Discount_Applied
  END;
  
# get month and year drop date col
ALTER TABLE retail2
ADD Transaction_Year text;

UPDATE retail2
	set Transaction_Year= CASE
		WHEN Transaction_Year is Null then year(Transaction_Date)
	    ELSE Transaction_Year
  END;
  
ALTER TABLE retail2
ADD Transaction_Month text;
  
  UPDATE retail2
  set Transaction_Month= CASE
    WHEN MONTH(Transaction_Date) = 1 THEN 'January'
    WHEN MONTH(Transaction_Date) = 2 THEN 'February'
    WHEN MONTH(Transaction_Date) = 3 THEN 'March'
    WHEN MONTH(Transaction_Date) = 4 THEN 'April'
    WHEN MONTH(Transaction_Date) = 5 THEN 'May'
    WHEN MONTH(Transaction_Date) = 6 THEN 'June'
    WHEN MONTH(Transaction_Date) = 7 THEN 'July'
    WHEN MONTH(Transaction_Date) = 8 THEN 'August'
    WHEN MONTH(Transaction_Date) = 9 THEN 'September'
    WHEN MONTH(Transaction_Date) = 10 THEN 'October'
    WHEN MONTH(Transaction_Date) = 11 THEN 'November'
    WHEN MONTH(Transaction_Date) = 12 THEN 'December'
    ELSE null
  END;
ALTER TABLE retail2
CHANGE `Transaction_Month` Transaction_Month text;

#make Item catergory look nicer
UPDATE retail2
SET Item = SUBSTRING_INDEX(Item, '_', 2);

#since 2025 is not complete we drop it
DELETE FROM retail2
WHERE Transaction_Year = 2025;


select * from retail2;


#catergory table prep
CREATE TABLE category_metrics AS
SELECT 
  cat.Category,
  cat.CategoryAmt,
  SUM(cat.CategoryAmt) OVER (
    ORDER BY cat.Category
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Catamt,
  cat.CategorySpent,
  SUM(cat.CategorySpent) OVER (
    ORDER BY cat.Category
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Catmoney
FROM (
  SELECT 
    Category,
    SUM(Quantity) AS CategoryAmt,
    SUM(Total_Spent) AS CategorySpent
  FROM retail2
  GROUP BY Category
) AS cat;
select * from category_metrics;

#item
CREATE TABLE item_metrics AS
SELECT 
  i.Item,
  i.ItemAmt,
  SUM(i.ItemAmt) OVER (
    ORDER BY i.ItemAmt
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Itemamt,
  i.ItemSpent,
  SUM(i.ItemSpent) OVER (
    ORDER BY i.item
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Itemmoney
FROM (
  SELECT 
    Item,
    SUM(Quantity) AS ItemAmt,
    SUM(Total_Spent) AS ItemSpent
  FROM retail2
  GROUP BY Item
) AS i;
select * from item_metrics;



#location
CREATE TABLE location_metrics AS
SELECT 
  loc.Location,
  loc.LocationAmt,
  SUM(loc.LocationAmt) OVER (
    ORDER BY loc.Location
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Locamt,
  loc.LocationSpent,
  SUM(loc.LocationSpent) OVER (
    ORDER BY loc.Location
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_LocMoney
FROM (
  SELECT 
    Location,
    SUM(Quantity) AS LocationAmt,
    SUM(Total_Spent) AS LocationSpent
  FROM retail2
  GROUP BY Location
) AS loc;
select * from location_metrics;

#payment method
CREATE TABLE pay_metrics AS
SELECT 
  pay.Payment_Method,
  pay.Payment_Method_Amt,
  SUM(pay.Payment_Method_Amt) OVER (
    ORDER BY pay.Payment_Method
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_PayMethodAmt,
  pay.Payment_Method_Spent,
  SUM(pay.Payment_Method_Spent) OVER (
    ORDER BY pay.Payment_Method
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_PayMethodSpent
FROM (
  SELECT 
    Payment_Method,
    SUM(Quantity) AS Payment_Method_Amt,
    SUM(Total_Spent) AS Payment_Method_Spent
  FROM retail2
  GROUP BY Payment_Method
) AS pay;
select * from pay_metrics;


#year/month
CREATE TABLE year_metrics AS
SELECT 
  y.Transaction_Year,
  y.Transaction_Year_Amt,
  SUM(y.Transaction_Year_Amt) OVER (
    ORDER BY y.Transaction_Year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Transaction_Year_Amt,
  y.Transaction_Year_Spent,
  SUM(y.Transaction_Year_Spent) OVER (
    ORDER BY y.Transaction_Year
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Transaction_Year_Spent
FROM (
  SELECT 
    Transaction_Year,
    SUM(Quantity) AS Transaction_Year_Amt,
    SUM(Total_Spent) AS Transaction_Year_Spent
  FROM retail2
  GROUP BY Transaction_Year
) AS y;
select * from year_metrics;

CREATE TABLE month_metrics AS
SELECT 
  m.Transaction_Month,
  m.Transaction_Month_Amt,
  SUM(m.Transaction_Month_Amt) OVER (
    ORDER BY m.Transaction_Month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Transaction_Month_Amt,
  m.Transaction_Month_Spent,
  SUM(m.Transaction_Month_Spent) OVER (
    ORDER BY m.Transaction_Month
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Transaction_Month_Spent
FROM (
  SELECT 
    Transaction_Month,
    SUM(Quantity) AS Transaction_Month_Amt,
    SUM(Total_Spent) AS Transaction_Month_Spent
  FROM retail2
  GROUP BY Transaction_Month
) AS m;
select * from month_metrics;


#discount
CREATE TABLE dis_metrics AS
SELECT 
  dis.Discount_Applied,
  dis.Discount_Applied_Amt,
  SUM(dis.Discount_Applied_Amt) OVER (
    ORDER BY dis.Discount_Applied
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_DiscountAmt,
 dis.Discount_Applied_Spent,
  SUM(dis.Discount_Applied_Spent) OVER (
    ORDER BY dis.Discount_Applied
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS Rolling_Total_Discount_Applied_Spent
FROM (
  SELECT 
    Discount_Applied,
    count(Discount_Applied) AS Discount_Applied_Amt,
    SUM(Total_Spent) AS Discount_Applied_Spent
  FROM retail2
  GROUP BY Discount_Applied
) AS dis;
select * from dis_metrics;

#most improved cat
CREATE TABLE improve AS
select
  Category,
  SUM(CASE WHEN Transaction_Year = 2023 THEN Total_Spent ELSE 0 END) AS Sales_2023,
  SUM(CASE WHEN Transaction_Year = 2024 THEN Total_Spent  ELSE 0 END) AS Sales_2024,
  SUM(CASE WHEN Transaction_Year = 2024 THEN Total_Spent  ELSE 0 END) - 
  SUM(CASE WHEN Transaction_Year = 2023 THEN Total_Spent  ELSE 0 END) AS Improvement
FROM retail2
GROUP BY Category
ORDER BY Improvement DESC;

select * from improve;

#create date numbering for ordering
CREATE TABLE monthnocounter AS
Select
  Transaction_Month,Transaction_Year,Total_Spent,
  CASE Transaction_Month
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
FROM retail2;
select * from monthnocounter;

#most improved item
CREATE TABLE improveitem AS
select
  Item,
  SUM(CASE WHEN Transaction_Year = 2023 THEN Total_Spent ELSE 0 END) AS Sales_2023,
  SUM(CASE WHEN Transaction_Year = 2024 THEN Total_Spent  ELSE 0 END) AS Sales_2024,
  SUM(CASE WHEN Transaction_Year = 2024 THEN Total_Spent  ELSE 0 END) - 
  SUM(CASE WHEN Transaction_Year = 2023 THEN Total_Spent  ELSE 0 END) AS Improvementitem
FROM retail2
GROUP BY Item
ORDER BY Improvementitem DESC;
select * from improveitem;