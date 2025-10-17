DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db; 

DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
    Order_Date DATE,
    "Time" TIME,
    Aging NUMERIC,
    Customer_Id TEXT,
    Gender TEXT,
    Device_Type TEXT,
    Customer_Login_type TEXT,
    Product_Category TEXT,
    Product TEXT,
    Sales NUMERIC,
    Quantity NUMERIC,
    Discount NUMERIC,
    Profit NUMERIC,
    Shipping_Cost NUMERIC,
    Order_Priority TEXT,
    Payment_method TEXT
);

\copy sales(
    Order_Date, "Time", Aging, Customer_Id, Gender, Device_Type, Customer_Login_type,
    Product_Category, Product, Sales, Quantity, Discount, Profit, Shipping_Cost,
    Order_Priority, Payment_method
)
FROM 'E-commerce_Dataset.csv'
DELIMITER ',' CSV HEADER;