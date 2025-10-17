--1 Calculate total sales, total profit, and total quantity sold for each Product_Category, sorted by total profit descending.
SELECT Product_Category,
SUM(Sales) AS total_sales,
SUM(Profit) AS total_profit,
SUM(Quantity) AS total_quantity
FROM sales
GROUP BY Product_Category
ORDER BY total_profit DESC


--2 Compute the average Aging for each Customer_Login_type, including only those with more than 3 orders.
SELECT Customer_Login_type,
AVG(Aging) as average_aging,
FROM sales
GROUP BY Customer_Login_type
HAVING COUNT(*) >=3


--3 Find the top 5 Customer_Ids by total profit, including total sales, total quantity, and number of orders.
SELECT Customer_Id,
SUM(Sales) AS total_sales,
SUM(Profit) AS total_profit,
SUM(Quantity) AS total_quantity,
COUNT(*) as number_of_orders
FROM sales
GROUP BY Customer_Id
ORDER BY total_profit DESC
LIMIT 5;

--4 For each Product_Category, calculate average discount, average profit, and the profit-to-discount ratio.
SELECT Product_Category,
AVG(Discount) AS average_discount,
AVG(Profit) AS avg_profit,
(AVG(Profit) /AVG(Discount)) AS ratio
from sales
GROUP BY Product_Category;


--5 Extract month and year from Order_Date and calculate total sales and quantity sold per month, ordered chronologically.
SELECT 
    EXTRACT(YEAR FROM Order_Date) AS order_year,
    EXTRACT(MONTH FROM Order_Date) AS order_month,
    SUM(Sales) AS total_sales,
    SUM(Quantity) AS total_quantity
FROM sales
GROUP BY 
    EXTRACT(YEAR FROM Order_Date),
    EXTRACT(MONTH FROM Order_Date)
ORDER BY 
    order_year,
    order_month;


--6 Retrieve all orders where Profit > 100 and Discount < 0.2, including Order_Date, Customer_Id, Product, and Profit.
SELECT Customer_Id, Order_Date, Product, Profit
FROM sales
WHERE Profit > 100 AND Discount < 0.2;


--7 For each Customer_Id, calculate number of orders, first order date, last order date, and average days between orders.
SELECT Customer_Id, 
COUNT(*) AS total_orders, 
MIN(Order_Date) AS first_order_date,
MAX(Order_Date) AS last_order_date,
 CASE 
        WHEN COUNT(*) > 1 THEN 
            EXTRACT(DAY FROM (MAX(Order_Date) - MIN(Order_Date))) / (COUNT(*) - 1)
        ELSE 0
    END AS avg_days_between_orders
FROM sales
GROUP BY Customer_Id


--8 Rank products within each Product_Category by total profit and return the top 3 products per category.
WITH product_revenue AS (
    SELECT 
        Product_Category,
        Product,
        SUM(Profit) AS total_profit,
        RANK() OVER (
            PARTITION BY Product_Category
            ORDER BY SUM(Profit) DESC
        ) AS profit_rank
    FROM sales
    GROUP BY Product_Category, Product
)
SELECT *
FROM product_revenue
WHERE profit_rank <=3



--9 For each Payment_method, calculate total number of orders, total sales, and average shipping cost, ranking by total sales descending.
WITH totals AS (
    SELECT 
        Payment_method,
        COUNT(*) AS total_no_orders,
        SUM(Sales) AS total_sales,
        AVG(Shipping_Cost) AS average_shipping_cost
    FROM sales
    GROUP BY Payment_method
    )
SELECT 
    Payment_method,
    total_no_orders,
    total_sales,
    average_shipping_cost,
    RANK() OVER (ORDER BY total_sales DESC) AS rank
FROM totals
ORDER BY total_sales DESC;


--10 Find the most profitable Product_Category among female customers using the Web who are members, including only orders with High or Critical priority.
SELECT Product_Category, 
SUM(Profit) AS total_profit
FROM sales
WHERE Gender = 'Female'
AND Device_Type = 'Web'
AND Customer_Login_type = 'Member'
AND Order_Priority IN ('High', 'Critical');



