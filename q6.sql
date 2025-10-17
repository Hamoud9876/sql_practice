--1 Top 5 Products by Profit Margin
-- Calculate Profit/Sales per product and find the top 5 products with the highest average profit margin.
SELECT Product,
AVG(Profit/Sales) as avg_profit_margin
FROM sales
GROUP BY Product
ORDER BY avg_profit_margin DESC
LIMIT 5;


--2 Customer Lifetime Value
-- For each Customer_Id, calculate total sales, total profit, number of orders, and average order value.
SELECT Customer_Id,
SUM(Sales) AS total_sales,
SUM(Profit) AS total_profit,
COUNT(*) AS number_of_orders,
AVG(Sales) AS avg_order_value
FROM sales
GROUP BY Customer_Id;


--3 Monthly Sales Growth Rate
-- For each month, calculate total sales and compute the month-over-month growth rate.
WITH months AS (
    SELECT EXTRACT (YEAR FROM Order_Date) as "year",
    EXTRACT (MONTH FROM Order_Date) as "month",
    SUM(Sales) as total_sales
    FROM sales
    GROUP BY EXTRACT (YEAR FROM Order_Date), EXTRACT (MONTH FROM Order_Date)
)

SELECT "year",
"month",
total_sales,
SUM(total_sales) OVER (ORDER BY "year", "month")
FROM months;


--4 Orders by Time of Day
-- Categorize orders into Morning (5–11), Afternoon (12–17), Evening (18–22), Night (23–4) using Time column and calculate total sales per period.
SELECT CASE WHEN EXTRACT (HOUR FROM "Time") BETWEEN 5 AND 11 THEN 'Morning'
WHEN EXTRACT (HOUR FROM "Time") BETWEEN 12 AND 17 THEN 'Afternoon'
WHEN EXTRACT (HOUR FROM "Time") BETWEEN 18 AND 22 THEN 'Evening'
ELSE 'Night'
END AS order_period,
SUM(Sales) as total_sales
from sales
GROUP BY order_period;



--5 Top 3 Products by Quantity per Customer
-- For each Customer_Id, find the top 3 products they purchased the most by quantity.
WITH top_product AS (
SELECT Customer_Id,
Product,
SUM(Quantity) as total_purchase
FROM sales
GROUP BY Customer_Id, Product
),
ranking AS(
    SELECT 
    Customer_Id,
    Product,
    total_purchase,
    RANK() OVER (PARTITION BY Customer_Id ORDER BY total_purchase DESC) as rank
    FROM top_product
)

SELECT Customer_Id, Product, total_purchase, rank
from ranking
where rank <=3
order by Customer_Id, rank;



--6 Average Profit per Device per Category
-- For each Product_Category and Device_Type, calculate average profit and rank devices within each category.
WITH product_profit AS (
SELECT Product_Category,
Product,
AVG(profit) as avg_profit
FROM sales
GROUP BY Product_Category, Product
)
SELECT Product_Category,
Product,
avg_profit,
RANK() OVER (PARTITION BY Product_Category ORDER BY avg_profit DESC) as rank
FROM product_profit
ORDER BY Product_Category, rank;




--7 High-Value Orders
-- Identify orders where Sales > 200 and Profit < 50, returning Customer_Id, Product, Sales, Profit, Profit/Sales.
SELECT Customer_Id,
Product,
Sales,
Profit,
(Profit/Sales) AS sales_margin
FROM sales
WHERE Sales > 200 AND Profit <50;


--8 Discount Impact on Profit per Category
-- For each Product_Category, calculate average discount, average profit, and determine correlation between discount and profit (using rank or trend).

SELECT Product_Category, 
AVG(Discount) as avg_discount,
AVG(Profit) as avg_profit,
CORR(Discount, Profit) as profit_discount_corr
FROM sales
GROUP BY Product_Category;


--9 Customer Churn Indicator
-- Identify customers who placed only one order in the dataset and return Customer_Id and Order_Date of that order.
SELECT Customer_Id,
MIN(Order_Date) AS order_date
FROM sales
GROUP BY Customer_Id
HAVING Count(*) = 1



--10 Shipping Cost vs. Profit Analysis
-- For each Product_Category, calculate average shipping cost, average profit, and the ratio of profit to shipping cost.
SELECT Product_Category,
AVG(Shipping_Cost) avg_shipping_cost,
AVG(Profit) as avg_profit,
(Profit / Shipping_Cost) as profit_Shipping_ratio
from sales
GROUP BY Product_Category;


