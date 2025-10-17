--1 Top 5 Customers by Total Profit
--Find the top 5 customers who generated the highest total profit.
SELECT Customer_Id,
SUM(Profit) as total_profit
FROM sales
GROUP BY Customer_Id
ORDER BY total_profit DESC
LIMIT 5


--2 Running Total of Sales per Customer by Month
--For each customer, show a running total of sales across months.
SELECT 
    Customer_Id,
    DATE_TRUNC('month', Order_Date) AS "month",
    SUM(Sales) AS monthly_sales,
    SUM(SUM(Sales)) OVER (
        PARTITION BY Customer_Id 
        ORDER BY DATE_TRUNC('month', Order_Date)
    ) AS running_total_sales
FROM sales
GROUP BY Customer_Id, DATE_TRUNC('month', Order_Date)
ORDER BY Customer_Id, "month";


--3 Top 3 Products per Month by Sales
--For each month, find the top 3 products by sales.
WITH monthly_product_sales AS (
    SELECT 
        Product,
        DATE_TRUNC('month', Order_Date) AS "month",
        SUM(Sales) AS monthly_sales
    FROM sales
    GROUP BY Product, DATE_TRUNC('month', Order_Date)
)
SELECT 
    Product,
    "month",
    monthly_sales,
    RANK() OVER (PARTITION BY "month" ORDER BY monthly_sales DESC) AS rank
FROM monthly_product_sales
WHERE RANK() OVER (PARTITION BY "month" ORDER BY monthly_sales DESC) <= 3
ORDER BY "month", rank;

--4 Customer Retention Rate
--Calculate the percentage of repeat customers per month.
WITH retention_rate AS(
Customer_Id,
DATE_TRUNC('month', Order_Date) AS "month",
COUNT(*) AS order_per_month
FROM sales
GROUP BY Customer_Id, DATE_TRUNC('month', Order_Date)
)
SELECT Customer_Id, "month",
(order_per_month + )


--5 Average Order Value by Device Type with Ranking
--Compute the average order value per device type and rank them.
WITH avg_device_order AS (
    SELECT 
        Device_Type,
        AVG(Sales) AS avg_order_value
    FROM sales
    GROUP BY Device_Type
)
SELECT 
    Device_Type,
    avg_order_value,
    RANK() OVER (ORDER BY avg_order_value DESC) AS rank
FROM avg_device_order
ORDER BY rank;



--6 Products with Increasing Sales Trend
--Identify products whose sales increased for at least 3 consecutive months.
WITH monthly_sales AS (
    SELECT 
        Product,
        DATE_TRUNC('month', Order_Date) AS month,
        SUM(Sales) AS total_sales
    FROM sales
    GROUP BY Product, DATE_TRUNC('month', Order_Date)
),
ranked_sales AS (
    SELECT
        Product,
        month,
        total_sales,
        LAG(total_sales, 1) OVER (PARTITION BY Product ORDER BY month) AS prev_month_sales,
        LAG(total_sales, 2) OVER (PARTITION BY Product ORDER BY month) AS prev2_month_sales
    FROM monthly_sales
)
SELECT DISTINCT Product
FROM ranked_sales
WHERE total_sales > prev_month_sales 
  AND prev_month_sales > prev2_month_sales
ORDER BY Product;



--7 Cohort Analysis: First Purchase Month
--Group customers by their first purchase month and calculate total revenue for each cohort over time.
WITH first_purchase AS (
    SELECT
        Customer_Id,
        DATE_TRUNC('month', MIN(Order_Date)) AS first_purchase_month
    FROM sales
    GROUP BY Customer_Id
),customer_sales AS (
    SELECT
        s.Customer_Id,
        f.first_purchase_month,
        DATE_TRUNC('month', s.Order_Date) AS order_month,
        SUM(s.Sales) AS monthly_sales
    FROM sales s
    JOIN first_purchase f
      ON s.Customer_Id = f.Customer_Id
    GROUP BY s.Customer_Id, f.first_purchase_month, DATE_TRUNC('month', s.Order_Date)
)

SELECT
    first_purchase_month AS cohort_month,
    order_month,
    SUM(monthly_sales) AS total_revenue
FROM customer_sales
GROUP BY first_purchase_month, order_month
ORDER BY cohort_month, order_month;



