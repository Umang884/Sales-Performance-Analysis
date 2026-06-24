--- Overview 
--- KPI( Total Sales , Total production cost, Total profit)
SELECT concat(round(sum(SaleAmount) / 1000000, 2), ' M') AS Total_sales FROM sales_data;
select concat(round(sum(ProductCost)/1000000,2),' M') as Total_Product_cost from sales_data;
select concat(round(sum(Profit)/1000000,2),' M') as Total_Profit from sales_data;
select concat(round(count(CustomerKey)/1000,3),' K') as Total_customers from customer;

---- 1. Yearly Sales Trend

SELECT year(OrderDate) AS Year ,concat(round(sum(SaleAmount) / 1000000, 2), ' M') AS Total_Sale FROM sales_data
GROUP BY Year
ORDER BY SUM(SaleAmount) DESC;
---- 2. Sales by Region (Sales Territory)
SELECT 
    st.SalesTerritoryRegion,
   concat(round(sum(SaleAmount) / 1000000, 4), ' M') AS Total_sales ,
   concat(round(sum(ProductCost)/1000000,4),' M') as Total_Product_cost,
   concat(round(sum(Profit)/1000000,4),' M') as Total_Profit ,
   concat(round((sum(Profit)/sum(SaleAmount))*100),' %') as Profit_Perctentage
FROM sales_data s
JOIN sales_territory st 
    ON s.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryRegion
ORDER BY Total_Sales DESC;

---- 3. Sales by Product Category

SELECT 
    p.ProductCategoryName AS Category,
    SUM(sd.SaleAmount) AS Total_Sales
FROM sales_data sd
JOIN product p
    ON sd.ProductKey = p.ProductKey
GROUP BY p.ProductCategoryName
ORDER BY Total_Sales DESC;

SELECT 
    p.ProductCategoryName AS Category,
    ROUND(SUM(sd.SaleAmount), 2) AS Total_Sales
FROM sales_data sd
JOIN product p
    ON sd.ProductKey = p.ProductKey
WHERE p.ProductCategoryName IS NOT NULL
AND p.ProductCategoryName <> ''
GROUP BY p.ProductCategoryName
HAVING SUM(sd.SaleAmount) > 0
ORDER BY Total_Sales DESC;


---- 4. Analyze customer distribution across regions to understand market presence

select st.SalesTerritoryRegion as Region ,count(sd.CustomerKey) as Customer_Distribution from sales_data sd
join sales_territory st
on sd.SalesTerritoryKey = st.SalesTerritoryKey
group by Region
order by Customer_Distribution desc;


---- part2. time series analysis
---  Yearly Sales Trend
select year(OrderDate) as Year , concat(round((sum(SaleAmount)/1000000),4),'M') as Total_Sales from sales_data
group by Year
order by sum(SaleAmount) desc;
--- monthly sale trend
SELECT 
    MONTHNAME(OrderDate) AS Month,
   concat(round((sum(SaleAmount)/1000000),4),'M') AS Total_Sales
FROM sales_data
GROUP BY Month
order by  sum(SaleAmount) desc;

--- Quarterly Trend
select ct. Quarter_Name ,  concat(round((sum(sd.SaleAmount)/1000000),4),'M') AS Total_Sales from sales_data sd
join calendar_table ct
on sd.OrderDateKey = ct.OrderDateKey
group by Quarter_Name
order by sum(sd.SaleAmount) desc;


--- 2. Identify seasonal patterns and peak sales periods

select ct.Year_No as Year, ct.MonthName, ct.Quarter_Name ,  concat(round((sum(sd.SaleAmount)/1000000),4),'M') AS Total_Sales from sales_data sd
join calendar_table ct
on sd.OrderDateKey = ct.OrderDateKey
group by ct.Year_No,ct.Quarter_Name,ct.MonthName
order by sum(sd.SaleAmount) desc;

--- 3.  Compare sales, production cost, and profit trends over year
--- 4.   Monitor overall business growth and performance changes

select ct.Year_No as Year, concat(round((sum(sd.SaleAmount)/1000000),4),'M') AS Total_Sales ,concat(round((sum(sd.ProductCost)/1000000),4),'M') AS Total_Product_Cost, 
concat(round((sum(sd.Profit)/1000000),4),'M') as Total_Profit, concat(round(sum(sd.Profit)/sum(sd.SaleAmount)*100,2)," %")as Profit_Percentage from sales_data sd
join calendar_table ct
on sd.OrderDateKey =ct.OrderDateKey
group by ct.Year_No
order by sum(sd.SaleAmount) desc;
--- part 3 . Customer Analysis
---  Analyze customer distribution across regions and countries
SELECT 
    st.SalesTerritoryRegion AS Region,
    COUNT(DISTINCT sd.CustomerKey) AS Total_Customers
FROM sales_data sd
JOIN sales_territory st
    ON sd.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryRegion
ORDER BY Total_Customers DESC;

SELECT 
    st.SalesTerritoryCountry AS Country,
    COUNT(DISTINCT sd.CustomerKey) AS Total_Customers
FROM sales_data sd
JOIN sales_territory st
    ON sd.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryCountry
ORDER BY Total_Customers DESC;

--- Identify repeat customers and customer retention trends

SELECT 
    CustomerKey,
    COUNT(SalesOrderNumber) AS Total_Orders
FROM sales_data
WHERE CustomerKey IS NOT NULL
AND CustomerKey <> ''
GROUP BY CustomerKey
HAVING COUNT(SalesOrderNumber) > 1
ORDER BY Total_Orders DESC;

---- Identify top customers based on sales
SELECT 
    c.CustomerKey,
    c.FullName,
    st.SalesTerritoryCountry AS Country,
    CONCAT(ROUND(SUM(sd.SaleAmount)/1000000, 4), 'M') AS Total_Sales
FROM sales_data sd
JOIN customer c
    ON sd.CustomerKey = c.CustomerKey
JOIN sales_territory st
    ON sd.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY 
    c.CustomerKey,
    c.FullName,
    st.SalesTerritoryCountry
ORDER BY SUM(sd.SaleAmount) DESC
LIMIT 10;

----- Analyze customer purchasing behavior across different markets 
SELECT 
    st.SalesTerritoryCountry AS Country,
    COUNT(DISTINCT sd.CustomerKey) AS Customers,
    COUNT(sd.SalesOrderNumber) AS Total_Orders,
    concat(round(sum(sd.SaleAmount) / 1000000, 2), ' M') AS Total_Sales,
    ROUND(AVG(sd.SaleAmount),2) AS Avg_Purchase_Value
FROM sales_data sd
JOIN sales_territory st
    ON sd.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryCountry
ORDER BY Total_Sales DESC;
---- part 4 Product & Regional Analysis
--- Sales Performance by Subcategory
SELECT 
    p.ProductSubcategoryName AS Subcategory,
  concat(round(sum(sd.SaleAmount) / 1000000, 2), ' M') AS Total_Sales,
  concat(round(sum(sd.Profit) / 1000000, 2), ' M')AS Total_Profit
FROM sales_data sd
JOIN product p
    ON sd.ProductKey = p.ProductKey
WHERE p.ProductSubcategoryName IS NOT NULL
GROUP BY p.ProductSubcategoryName
ORDER BY Total_Sales DESC;

----  Identify top-selling and high-profit products
SELECT p.EnglishProductName as ProductName,
    concat(round(sum(sd.SaleAmount) / 1000000, 2), ' M')AS Total_Sales, concat(round(sum(sd.Profit) / 1000000, 2), ' M') AS Total_Profit
FROM sales_data sd
JOIN product p
    ON sd.ProductKey = p.ProductKey
GROUP BY ProductName
ORDER BY Total_Sales DESC
LIMIT 10;
-----  Detect low-profit or loss-making products for cost reduction
SELECT 
    p.EnglishProductName as ProductName, concat(round(sum(sd.Profit) / 1000000, 2), ' M') AS Low_Profit FROM sales_data sd
JOIN product p
    ON sd.ProductKey = p.ProductKey
GROUP BY ProductName
HAVING SUM(sd.Profit) <= 0
ORDER BY Low_profit desc;
---- Compare regional sales and profit performance to identify top-performing markets
SELECT 
    st.SalesTerritoryCountry AS Country,
   concat(round(sum(sd.SaleAmount) / 1000000, 2), ' M') AS Total_Sales,
    concat(round(sum(sd.Profit) / 1000000, 2), ' M')AS Total_Profit
FROM sales_data sd
JOIN sales_territory st
    ON sd.SalesTerritoryKey = st.SalesTerritoryKey
GROUP BY st.SalesTerritoryCountry
ORDER BY Total_Sales DESC;