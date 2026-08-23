 
 use retail_sales;
 -- ============================================
-- RETAIL SALES ANALYSIS PROJECT
-- SECTION 1: BUSINESS OVERVIEW
-- ============================================

-- 1. Total Sales, Cost, Profit & Profit Margin

SELECT
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales;  


-- 2. Total Orders & Unique Customers

SELECT
    COUNT(*) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers
FROM retail_sales; 

-- 3. Average Order Value

SELECT
    ROUND(AVG(Sales_Amount), 2) AS Average_Order_Value
FROM retail_sales;


-- ============================================
-- SECTION 2: SALES ANALYSIS
-- ============================================

-- 1. Category-wise Sales & Profit

SELECT
    Category,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales
GROUP BY Category
ORDER BY Total_Sales DESC;


-- 2. Region-wise Sales & Profit

SELECT
    Region,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Cost) AS Total_Cost,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales
GROUP BY Region
ORDER BY Total_Sales DESC;


-- 3. Monthly Sales Trend

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    MONTHNAME(Order_Date) AS Month_Name,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM retail_sales
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)
ORDER BY Sales_Year, Sales_Month;


-- ============================================
-- SECTION 3: PRODUCT & PAYMENT ANALYSIS
-- ============================================

-- 1. Top 10 Products by Sales

SELECT
    Product,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales
GROUP BY Product
ORDER BY Total_Sales DESC
LIMIT 10;


-- 2. Payment Mode Analysis

SELECT
    Payment_Mode,
    COUNT(*) AS Total_Orders,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales
GROUP BY Payment_Mode
ORDER BY Total_Sales DESC;


-- 3. Product Profit Margin Analysis

SELECT
    Product,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    ROUND((SUM(Profit) / SUM(Sales_Amount)) * 100, 2) AS Profit_Margin
FROM retail_sales
GROUP BY Product
ORDER BY Profit_Margin ASC;


-- ============================================
-- SECTION 4: CUSTOMER ANALYSIS
-- ============================================

-- 1. Top 10 Customers by Sales

SELECT
    Customer_ID,
    Customer_Name,
    COUNT(*) AS Total_Orders,
    SUM(Sales_Amount) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM retail_sales
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;


-- 2. Repeat Customers

SELECT
    COUNT(*) AS Repeat_Customers
FROM (
    SELECT Customer_ID
    FROM retail_sales
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
) AS Repeat_Customers;


-- 3. Customer Value Segmentation

WITH Customer_Sales AS (
    SELECT
        Customer_ID,
        SUM(Sales_Amount) AS Total_Sales
    FROM retail_sales
    GROUP BY Customer_ID
)
SELECT
    Customer_ID,
    Total_Sales,
    CASE
        WHEN Total_Sales >= 300000 THEN 'High Value'
        WHEN Total_Sales >= 150000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment
FROM Customer_Sales
ORDER BY Total_Sales DESC;


-- ============================================
-- SECTION 5: ADVANCED SQL ANALYSIS
-- ============================================

-- 1. Top 3 Products by Category

WITH Product_Sales AS (
    SELECT
        Category,
        Product,
        SUM(Sales_Amount) AS Total_Sales
    FROM retail_sales
    GROUP BY Category, Product
),
Ranked_Products AS (
    SELECT
        Category,
        Product,
        Total_Sales,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Sales_Rank
    FROM Product_Sales
)
SELECT
    Category,
    Product,
    Total_Sales,
    Sales_Rank
FROM Ranked_Products
WHERE Sales_Rank <= 3
ORDER BY Category, Sales_Rank;


-- 2. Month-over-Month Sales Growth

WITH Monthly_Sales AS (
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        MONTHNAME(Order_Date) AS Month_Name,
        SUM(Sales_Amount) AS Total_Sales
    FROM retail_sales
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        MONTHNAME(Order_Date)
),
Sales_With_Previous AS (
    SELECT
        Sales_Year,
        Sales_Month,
        Month_Name,
        Total_Sales,
        LAG(Total_Sales) OVER (
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Sales
    FROM Monthly_Sales
)
SELECT
    Sales_Year,
    Sales_Month,
    Month_Name,
    Total_Sales,
    Previous_Month_Sales,
    ROUND(
        ((Total_Sales - Previous_Month_Sales)
        / Previous_Month_Sales) * 100,
        2
    ) AS MoM_Growth_Percentage
FROM Sales_With_Previous
ORDER BY Sales_Year, Sales_Month;


-- 3. Running Total Sales

SELECT
    Order_Date,
    Sales_Amount,
    SUM(Sales_Amount) OVER (
        ORDER BY Order_Date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS Running_Total_Sales
FROM retail_sales
ORDER BY Order_Date;


-- 4. Top 5 Customers by Profit

WITH Customer_Profit AS (
    SELECT
        Customer_ID,
        Customer_Name,
        SUM(Profit) AS Total_Profit
    FROM retail_sales
    GROUP BY Customer_ID, Customer_Name
),
Ranked_Customers AS (
    SELECT
        Customer_ID,
        Customer_Name,
        Total_Profit,
        RANK() OVER (
            ORDER BY Total_Profit DESC
        ) AS Profit_Rank
    FROM Customer_Profit
)
SELECT
    Customer_ID,
    Customer_Name,
    Total_Profit,
    Profit_Rank
FROM Ranked_Customers
WHERE Profit_Rank <= 5
ORDER BY Profit_Rank;


-- ============================================
-- SECTION 6: BUSINESS INSIGHTS
-- ============================================

-- 1. Electronics generated the highest sales.
-- 2. Accessories had the highest category profit margin.
-- 3. South region generated the highest sales.
-- 4. North region had the highest regional profit margin.
-- 5. Laptop was the top product by sales.
-- 6. Mouse had the highest product profit margin.
-- 7. UPI generated the highest sales among payment modes.
-- 8. September had the highest monthly sales.
-- 9. May had the highest month-over-month sales growth.
-- 10. October had the largest month-over-month sales decline.
-- 11. 149 out of 150 customers were repeat customers.
-- 12. High-value customers contributed the largest share of sales.
-- 13. Anitha (CUST1083) was the top customer by sales and profit.
-- 14. Average Order Value was ₹4,646.98.





