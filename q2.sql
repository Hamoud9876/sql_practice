--Cumulative Revenue Over Time
---Show the cumulative total revenue for each day.
SELECT
    Order_Date,
    SUM(Sales) AS daily_revenue,
    SUM(SUM(Sales)) OVER (ORDER BY Order_Date) AS cumulative_revenue
FROM sales
GROUP BY Order_Date
ORDER BY Order_Date;

--Rank Customers by Total Spending
---Rank all customers based on their total spending, with the highest spender first.
SELECT Customer_Id, 
SUM(Sales) AS total_spending,
RANK() OVER (ORDER BY SUM(Sales) DESC) AS Rank


--Top 3 Products per Category by Sales
---For each product category, find the top 3 products by total sales.
WITH ranked_products AS (
    SELECT 
        Product_Category,
        Product,
        SUM(Sales) AS total_sales,
        RANK() OVER (PARTITION BY Product_Category ORDER BY SUM(Sales) DESC) AS rank
    FROM sales
    GROUP BY Product_Category, Product
)
SELECT *
FROM ranked_products
WHERE rank <= 3
ORDER BY Product_Category, rank;


--Average Order Value per Customer with Ranking
---Calculate the average order value per customer and rank them within their gender group.
WITH customer_avg AS (
    SELECT
        Customer_Id,
        Gender,
        AVG(Sales) AS avg_order_value
    FROM sales
    GROUP BY Customer_Id, Gender
)
SELECT
    Customer_Id,
    Gender,
    avg_order_value,
    RANK() OVER (PARTITION BY Gender ORDER BY avg_order_value DESC) AS rank
FROM customer_avg
ORDER BY Gender, rank;

--Running Total of Orders per Customer
---For each customer, show a running total of their number of orders over time.
SELECT Customer_Id,
    COUNT(*) OVER (PARTITION BY Customer_Id ORDER BY Order_Date) AS running_total
FROM sales
ORDER BY Customer_Id, running_total;


--6 Percentage Contribution by Product Category
---Calculate each product category’s percentage contribution to total revenue.
SELECT 
    Product_Category,
    SUM(Sales) AS category_sales,
    ROUND(
        SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 
        2
    ) AS percentage_contribution
FROM sales
GROUP BY Product_Category
ORDER BY percentage_contribution DESC;


--7 Monthly Revenue with Month-over-Month Growth
---Compute the total revenue per month and the percentage growth compared to the previous month.
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', Order_Date) AS month,
        SUM(Sales) AS monthly_revenue
    FROM sales
    GROUP BY DATE_TRUNC('month', Order_Date)
)
SELECT 
    month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        ((monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY month))
          / NULLIF(LAG(monthly_revenue) OVER (ORDER BY month), 0)) * 100,
        2
    ) AS month_over_month_growth
FROM monthly_sales
ORDER BY month;


--8 Identify Repeat vs One-Time Customers
---Classify customers as “Repeat” if they have more than one order, otherwise “One-Time”.
SELECT Customer_Id,
CASE WHEN COUNT(Order_Date) >1 THEN "One-Time" ELSE "Repeat" END AS custmoer_type
FROM sales
GROUP BY Customer_Id;


--Highest Profit Orders per Customer
---For each customer, find the single order that generated the highest profit.
WITH customers_profit AS (
    SELECT 
        Customer_Id,
        SUM(Sales) AS customer_profit
    FROM sales
    GROUP BY Customer_Id
),
ranked_customers AS (
    SELECT 
        Customer_Id,
        customer_profit,
        RANK() OVER (ORDER BY customer_profit DESC) AS rank
    FROM customers_profit
)
SELECT *
FROM ranked_customers
WHERE rank = 1;


--Discount Effect on Average Profit per Product
---Calculate the average profit per product at each discount level and identify which discounts are most profitable.
SELECT 
    Product,
    Discount,
    AVG(Profit) AS avg_profit
FROM sales
GROUP BY Product, Discount
ORDER BY Discount DESC, avg_profit DESC;
