--1 Top Selling Products by Quantity
-- Find the top 5 products with the highest total quantity sold across all orders.
SELECT Product,
SUM(Quantity) AS total_quantity
FROM sales
GROUP BY Products
ORDER BY total_quantity DESC
LIMIT 5;

--2 Monthly Profit Trend
-- Calculate total profit per month (year + month) and show a cumulative profit over time.
WITH dates AS (
    SELECT
    SUM(Profit) as total_profit,
    EXTRACT (YEAR FROM (Order_Date)) AS "year",
EXTRACT (MONTH FROM (Order_Date)) AS "month"
FROM sales 
GROUP BY EXTRACT (YEAR FROM (Order_Date)), EXTRACT (MONTH FROM (Order_Date))
)
SELECT "year",
"month",
SUM(total_profit) OVER (ORDER BY "year", "month")
FROM dates;


--3 Customer Segmentation by Spending
-- For each Customer_Id, calculate total sales and classify customers into:

-- Gold: total sales > 1000

-- Silver: total sales 500–1000

-- Bronze: total sales < 500
SELECT Customer_Id, 
SUM(Sales) as total_sales,
CASE WHEN SUM(Sales) > 1000 THEN 'Gold'
     WHEN SUM(Sales) < 500 THEN 'Bronze'
     ELSE 'Silver'
     END as tier
FROM sales
GROUP BY Customer_Id;

--4 High Discount Impact on Profit
-- Identify all products where the average discount is greater than 0.25 and calculate the average profit for those products.
SELECT Product,
avg(Profit) as average_profit
from sales
GROUP BY Product
HAVING AVG(Discount) >0.25;


--5 Orders per Priority Level
-- For each Order_Priority, calculate total number of orders, total sales, and average aging.
SELECT Order_Priority, 
COUNT(*) as total_orders,
SUM(Sales) as total_sales,
AVG(Aging) as average_aging
from sales
GROUP BY Order_Priority;


--6 Most Profitable Device Type per Category
-- For each Product_Category, find the Device_Type that contributed the highest total profit.
WITH category_device_profit AS (
    SELECT 
        Product_Category,
        Device_Type,
        SUM(Profit) AS total_profit
    FROM sales
    GROUP BY Product_Category, Device_Type
)
SELECT 
    Product_Category,
    Device_Type,
    total_profit
FROM (
    SELECT 
        *,
        RANK() OVER (PARTITION BY Product_Category ORDER BY total_profit DESC) AS rank
    FROM category_device_profit
) ranked
WHERE rank = 1;


--7 Customer Repeat Rate
-- Calculate the percentage of customers who placed more than one order.
WITH mult_orders AS (
    SELECT Customer_Id
    FROM sales
    GROUP BY Customer_Id
    HAVING COUNT(Customer_Id) >=2
)
SELECT (COUNT(Customer_Id) / (SELECT COUNT(DISTINCT Customer_Id) from sales)) * 100 as multi_order_percentage
FROM mult_orders

--8 Profit Contribution by Payment Method
-- For each Payment_method, calculate the percentage of total profit it contributed to the overall profit.
WITH profit_by_payment as (
SELECT Payment_method, 
SUM(Profit) as total_profit
FROM sales
GROUP BY Payment_method
)

SELECT Payment_method,
(total_profit / (SELECT SUM(Profit) FROM sales )) * 100 as profit_ratio
from profit_by_payment;


--9 Top 3 Customers per Product Category
-- For each Product_Category, find the top 3 customers by total profit using window functions.
WITH som AS (
    select 
    Product_Category,
Customer_Id,
SUM(Profit) AS total_profit
FROM sales
GROUP BY Product_Category, Customer_Id
), ranking AS (
    SELECT Product_Category,
    Customer_Id,
    RANK() OVER (PARTITION BY Product_Category ORDER BY total_profit DESC) as rank
    from som
)
SELECT Product_Category,
Customer_Id,
rank
from ranking
where rank <=3 ;


--10 Orders with Extreme Profit Margins
-- Identify orders where the profit margin (Profit / Sales) is greater than 0.8 or less than 0.1, and return Customer_Id, Product, Profit, Sales, and Profit/Sales.
SELECT Customer_Id,
Product,
Sales,
Profit
FROM sales
WHERE (Profit/Sales) >0.8 OR (Profit/Sales) <0.1;



