-- =========================================================
-- SUPERSTORE SALES AND PROFITABILITY ANALYSIS
-- MySQL analysis of category, subcategory, and discount performance
-- =========================================================

-- 01. DATABASE AND TABLE SETUP
CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;

-- Reset this project's table so the script can be run again.
-- This permanently deletes any existing data in orders.
DROP TABLE IF EXISTS orders;

CREATE TABLE IF NOT EXISTS orders (
    row_id        INT PRIMARY KEY,
    order_id      VARCHAR(20),
    order_date    DATE,
    ship_date     DATE,
    ship_mode     VARCHAR(20),
    customer_id   VARCHAR(20),
    customer_name VARCHAR(100),
    segment       VARCHAR(20),
    country       VARCHAR(50),
    city          VARCHAR(50),
    state         VARCHAR(50),
    postal_code   VARCHAR(10),
    region        VARCHAR(20),
    product_id    VARCHAR(20),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    product_name  VARCHAR(255),
    sales         DECIMAL(10,2),
    quantity      INT,
    discount      DECIMAL(6,2),
    profit        DECIMAL(10,2)
);

-- Should be done both at MySQL and at Client(may require admin permission, you can do it in mysql command line client).
SET GLOBAL local_infile = 1;

-- To look if local_infile is on in MySQL
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- 02. DATA IMPORT
-- LOAD DATA LOCAL INFILE LOCAL INFILE require LOCAL INFILE to be enabled on both the MySQL server and the client. 
-- Load procedure to load data from the dataset csv.
-- Update the CSV path before running this section.
LOAD DATA LOCAL INFILE 'C:/path/to/super_store.csv'
INTO TABLE orders
CHARACTER SET latin1
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(row_id, order_id, @order_date, @ship_date, ship_mode, customer_id, customer_name,
 segment, country, city, state, postal_code, region, product_id, category,
 sub_category, product_name, sales, quantity, discount, profit)
 -- change the 
SET
  order_date = STR_TO_DATE(@order_date, '%m/%d/%Y'),
  ship_date  = STR_TO_DATE(@ship_date, '%m/%d/%Y');


-- 03. DATA VALIDATION
SELECT COUNT(*) FROM orders; -- should be 9994
SELECT * FROM orders LIMIT 5;
SELECT MIN(order_date), MAX(order_date) FROM orders;  -- should be 2014-01-03 to 2017-12-30
SELECT COUNT(*) FROM orders WHERE order_date IS NULL; -- should be 0 — catches date parsing failures

SELECT COUNT(DISTINCT(order_id)) FROM orders;
-- 5009 orders.


-- 04. BUSINESS QUESTIONS
-- How is the performance of each category and subcategory?
-- Are profit and sales concentrated in some specific products?
-- How did each category and subcategory perform over time?
-- Do discounts actually affect orders, quantity sold, and overall profitability?


-- 05. CATEGORY PERFORMANCE
-- Performance of category over 4 years
SELECT category, COUNT(*) total_records, COUNT(DISTINCT(order_id)) total_orders, SUM(sales) total_sales, 
SUM(profit) total_profit, ROUND(SUM(profit) / SUM(sales) * 100, 2)profit_margin,
ROUND(SUM(sales) / SUM(SUM(sales)) OVER() * 100, 2) pct_of_sales,
ROUND(SUM(profit) / SUM(SUM(profit)) OVER() * 100, 2) pct_of_profit
FROM orders GROUP BY category ORDER BY profit_margin DESC;
-- Sales are relatively even, while profit are dominated by techcnology and Office supplies.
-- Technology is the most profitable category, with the most sales and profit. 
-- Office supplies, while having the most orders, is second to technology in performance.
-- Furniture is the least profitable category, having the lowest profit margin, 2.49%, while the other have around 17%.

-- performance of category 2017 only
SELECT category, COUNT(*) total_records, COUNT(DISTINCT(order_id)) total_orders, SUM(sales) total_sales, 
SUM(profit) total_profit, ROUND(SUM(profit) / SUM(sales) * 100, 2)profit_margin,
ROUND(SUM(sales) / SUM(SUM(sales)) OVER() * 100, 2) pct_of_sales,
ROUND(SUM(profit) / SUM(SUM(profit)) OVER() * 100, 2) pct_of_profit
FROM orders WHERE order_date >= '2017-01-01' GROUP BY category ORDER BY profit_margin DESC;
-- Sales are relatively even, while profit are dominated by tehcnology and Office supplies.
-- Technology is the most profitable category, with the most sales and profit. 
-- Office supplies, while having the most orders, is second to technology in performance.
-- For 2017, furniture has the lowest profit margin (1.40%), while office supplies and technology have 16.15% and 18.65% profit margins.


-- 06. SUBCATEGORY PERFORMANCE
SELECT COUNT(DISTINCT(sub_category)) FROM orders;
-- There are 17 subcategories.

-- performance of subcategory over 4 years
SELECT sub_category, category, COUNT(*) total_records, COUNT(DISTINCT(order_id)) total_orders, SUM(sales) total_sales, 
SUM(SUM(sales)) OVER() whole_total_sales,
ROUND(SUM(sales)/SUM(SUM(sales)) OVER() * 100, 2) pct_of_whole_total_sales,
SUM(profit) total_profit, 
SUM(SUM(profit)) OVER() whole_total_profit,
ROUND(SUM(profit)/SUM(SUM(profit)) OVER() * 100, 2) pct_of_whole_total_profit,
ROUND(SUM(profit) / SUM(sales) * 100, 2) profit_margin
FROM orders GROUP BY sub_category, category ORDER BY profit_margin DESC;
-- Top 3 highest profit margin = labels(44.42%), paper(43.39%), and envelopes(42.27%)
-- Bottom 3 lowest profit margin = tables(-8.56%), bookcases(-3.02%), and supplies(-2.55%)
-- Sales are distributed quite unevenly across all subcategories, with phones at the top(14.37%), with the top 5 subcateogries contributing to 56.27% of total sales.
-- Profit is distributed unevenly across all subcategories, with copiers at the top(19.42%), with the top 3 subcateogries contributing to 49.6% of total profit.
-- Notes: 3 subcategories contributed negatively to the overall share of profit: tables(-6.19%), bookcases(-1.21%), and supplies(-0.42%).
-- 100% / 17 = 5.9%

-- performance of subcategory 2017 only
SELECT sub_category, category, COUNT(*) total_records, COUNT(DISTINCT(order_id)) total_orders, SUM(sales) total_sales, 
SUM(SUM(sales)) OVER() whole_total_sales,
ROUND(SUM(sales)/SUM(SUM(sales)) OVER() * 100, 2) pct_of_whole_total_sales,
SUM(profit) total_profit, 
SUM(SUM(profit)) OVER() whole_total_profit,
ROUND(SUM(profit)/SUM(SUM(profit)) OVER() * 100, 2) pct_of_whole_total_profit,
ROUND(SUM(profit) / SUM(sales) * 100, 2) profit_margin
FROM orders WHERE order_date >= '2017-01-01' 
GROUP BY sub_category, category ORDER BY profit_margin DESC;
-- Top 3 highest profit margin = labels(45.18%), paper(43.48%), and envelopes(42.67%)
-- Bottom 4 lowest profit margin = tables(-13.37%), machines(-6.59%), supplies(-5.95%), and bookcases(-1.94%)
-- Sales are distributed quite unevenly across all subcategories, with phones at the top(14.37%), with the top 5 subcateogries contributing to 55.41% of total sales.
-- Profit is distributed unevenly across all subcategories, with copiers at the top(26.79%), with the top 3 subcateogries contributing to 57.31% of total profit.
-- Notes: 4 subcategories contributed negatively to the overall share of profit: tables(-8.71%), machines(-3.07%), supplies(-1.02%), and bookcases(-0.62%).


-- 07. PERFORMANCE TRENDS
-- category
WITH yearly AS (
SELECT category, COUNT(*) total_records,
YEAR(order_date) AS order_year,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM orders
GROUP BY category, YEAR(order_date)
)
SELECT category, order_year, total_records, total_sales, total_profit, ROUND(total_profit/total_sales * 100, 2) pct_profit_margin,
ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY category ORDER BY order_year))
/ LAG(total_sales) OVER (PARTITION BY category ORDER BY order_year) * 100, 2) AS sales_growth_pct,
ROUND((total_profit - LAG(total_profit) OVER (PARTITION BY category ORDER BY order_year))
/ LAG(total_profit) OVER (PARTITION BY category ORDER BY order_year) * 100, 2) AS profit_growth_pct
FROM yearly
ORDER BY category, order_year;
-- Technology and office supplies are growing healthily in both sales(except 2015) and profit, while furniture is growing healthily in sales but volatile in profit.
-- By 2017, furniture profit margin fell to 1.40% from 3.47% in 2014, while office supplies rose from 14.89% to 16.15%,
-- and technology rose from 12.26% to 18.65% 

-- subcategory
WITH yearly AS (
SELECT sub_category, category, YEAR(order_date) AS order_year, COUNT(*) AS total_records,
SUM(sales) AS total_sales, SUM(profit) AS total_profit
FROM orders
GROUP BY sub_category, category, YEAR(order_date)
)
SELECT sub_category, category, order_year, total_records, total_sales, total_profit,
ROUND(total_profit / total_sales * 100, 2) AS profit_margin_pct,
total_sales - LAG(total_sales) OVER (PARTITION BY sub_category ORDER BY order_year) AS sales_change,
CASE WHEN LAG(total_sales) 
OVER (PARTITION BY sub_category ORDER BY order_year) > 0
THEN ROUND((total_sales - LAG(total_sales) OVER (PARTITION BY sub_category ORDER BY order_year)) 
/ LAG(total_sales) OVER (PARTITION BY sub_category ORDER BY order_year) * 100, 2)
ELSE NULL 
END AS sales_growth_pct,
total_profit - LAG(total_profit) OVER (PARTITION BY sub_category ORDER BY order_year) AS profit_change,
CASE WHEN LAG(total_profit) 
OVER (PARTITION BY sub_category ORDER BY order_year) > 0
THEN ROUND((total_profit - LAG(total_profit) OVER (PARTITION BY sub_category ORDER BY order_year)) 
/ LAG(total_profit) OVER (PARTITION BY sub_category ORDER BY order_year) * 100, 2)
ELSE NULL
END AS profit_growth_pct
FROM yearly
ORDER BY category, sub_category, order_year;
-- bookcases, tables, supplies, and machines are all unprofitable by the end of 2017, 
-- With bookcases, tables, and supplies having a profit margin below 1% for 3 years in a row.


-- 04.1 EXTRA QUESTION:
-- Why are bookcases, tables, supplies, and machines unprofitable or performing badly? 


-- 08. DISCOUNT ANALYSIS (DRIVER)
SELECT ROUND((SELECT COUNT(*) FROM orders WHERE discount > 0 ) / COUNT(*) * 100, 2) pct_of_discounted_records,
ROUND((SELECT COUNT(DISTINCT(order_id)) FROM orders WHERE discount > 0 ) / COUNT(DISTINCT(order_id)) * 100, 2) pct_of_discounted_orders 
FROM orders;
-- discounted records contributed to 51.99% of total records.
-- discounted orders contributed to 58.97% of total orders.

-- category
WITH d AS( 
SELECT *, CASE WHEN discount > 0 THEN 'yes' ELSE 'no' END AS discount_status FROM orders) 
SELECT category,
AVG(CASE WHEN discount_status = 'yes' THEN quantity END) AS avg_quantity_with_discount,
SUM(CASE WHEN discount_status = 'yes' THEN quantity END) AS total_quantity_with_discount,
AVG(CASE WHEN discount_status = 'no' THEN quantity END) AS avg_quantity_without_discount,
SUM(CASE WHEN discount_status = 'no' THEN quantity END) AS total_quantity_without_discount,
AVG(CASE WHEN discount_status = 'yes' THEN quantity END) - 
AVG(CASE WHEN discount_status = 'no' THEN quantity END) AS diff_q_avg_discount_vs_no,
SUM(CASE WHEN discount_status = 'yes' THEN quantity END) - 
SUM(CASE WHEN discount_status = 'no' THEN quantity END) AS diff_q_sum_discount_vs_no,
ROUND(SUM(CASE WHEN discount_status = 'yes' THEN profit END) / SUM(CASE WHEN discount_status = 'yes' THEN sales END)* 100, 2) pct_profit_margin_with_discount,
ROUND(SUM(CASE WHEN discount_status = 'no' THEN profit END) / SUM(CASE WHEN discount_status = 'no' THEN sales END)* 100, 2) pct_profit_margin_without_discount,
ROUND(SUM(CASE WHEN discount_status = 'no' THEN profit END) / SUM(CASE WHEN discount_status = 'no' THEN sales END)* 100, 2) -
ROUND(SUM(CASE WHEN discount_status = 'yes' THEN profit END) / SUM(CASE WHEN discount_status = 'yes' THEN sales END)* 100, 2) disc_vs_ndisc_profit_margin
FROM d
GROUP BY category
ORDER BY diff_q_avg_discount_vs_no;
-- Furniture and Office supplies profit margin with discount is negative. Average quantity per item purchased with a discount vs without is nearly identical.

-- sub category
-- four-year aggregate margin
WITH d AS( 
SELECT *, CASE WHEN discount > 0 THEN 'yes' ELSE 'no' END AS discount_status FROM orders) 
SELECT sub_category,
AVG(CASE WHEN discount_status = 'yes' THEN quantity END) AS avg_quantity_with_discount,
SUM(CASE WHEN discount_status = 'yes' THEN quantity END) AS total_quantity_with_discount,
AVG(CASE WHEN discount_status = 'no' THEN quantity END) AS avg_quantity_without_discount,
SUM(CASE WHEN discount_status = 'no' THEN quantity END) AS total_quantity_without_discount,
AVG(CASE WHEN discount_status = 'yes' THEN quantity END) - 
AVG(CASE WHEN discount_status = 'no' THEN quantity END) AS diff_q_avg_discount_vs_no,
SUM(CASE WHEN discount_status = 'yes' THEN quantity END) - 
SUM(CASE WHEN discount_status = 'no' THEN quantity END) AS diff_q_sum_discount_vs_no,
ROUND(SUM(CASE WHEN discount_status = 'yes' THEN profit END) / SUM(CASE WHEN discount_status = 'yes' THEN sales END)* 100, 2) pct_profit_margin_with_discount,
ROUND(SUM(CASE WHEN discount_status = 'no' THEN profit END) / SUM(CASE WHEN discount_status = 'no' THEN sales END)* 100, 2) pct_profit_margin_without_discount,
ROUND(SUM(CASE WHEN discount_status = 'no' THEN profit END) / SUM(CASE WHEN discount_status = 'no' THEN sales END)* 100, 2) -
ROUND(SUM(CASE WHEN discount_status = 'yes' THEN profit END) / SUM(CASE WHEN discount_status = 'yes' THEN sales END)* 100, 2) disc_vs_ndisc_profit_margin
FROM d
GROUP BY sub_category
ORDER BY diff_q_avg_discount_vs_no;
-- Across nearly every sub-category, average quantity per item purchased with a discount vs without is nearly identical.
-- Discounted vs non-discounted orders have a high difference in profit margin on average; the highest difference is machines (58.29%), and the lowest is fasteners (11.03%).
-- Tables, machines, supplies, appliances, furnishing, bookcases, binders, and storage all have positive profit margins until they are discounted.

-- yearly average for tables, machines, bookcases, and supplies
WITH d AS( 
SELECT *, CASE WHEN discount > 0 THEN 'yes' ELSE 'no' END AS discount_status FROM orders) 
SELECT sub_category, category, YEAR(order_date) year, 
COUNT(*) total_records,
ROUND(AVG(CASE WHEN discount_status ='yes' THEN discount END) * 100, 2) avg_discount, 
ROUND(SUM(CASE WHEN discount_status = 'yes' THEN profit END) / SUM(CASE WHEN discount_status = 'yes' THEN sales END)* 100, 2) pct_profit_margin_with_discount,
ROUND(SUM(CASE WHEN discount_status = 'no' THEN profit END) / SUM(CASE WHEN discount_status = 'no' THEN sales END)* 100, 2) pct_profit_margin_without_discount,
SUM(CASE WHEN discount > 0 THEN sales ELSE 0 END) AS discounted_sales,
SUM(sales) total_sales,
ROUND(SUM(CASE WHEN discount > 0 THEN sales ELSE 0 END) / SUM(sales) * 100, 2) pct_dollars_discounted,
ROUND(SUM(CASE WHEN discount > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) pct_purchase_discounted,
SUM(profit) total_profit
FROM d WHERE sub_category in ('Machines', 'Supplies', 'Bookcases', 'Tables')
GROUP BY sub_category, category, YEAR(order_date)
ORDER BY sub_category, category, YEAR(order_date);
-- The level of discount is relatively stable on average every year. 
-- Every year, these 4 products sell at a loss when selling on discount.
-- Most of the sales come from discounted orders for bookcases, machines, and tables, around 65%-80% of total sales.
-- Supplies by itself at normal have a really thin profit margin (5.45%, 4-year avg), where with a 20% flat discount it will have a negative aggregate profit margins.
-- Supplies only have a positive year in 2014, when its pct dollar discounted / pct of discounted sales to total sales is only 3.39%. This loss from discounts can still be covered by its low margin.

-- Range of discount in each bottom 4
SELECT sub_category, category, MAX(discount), MIN(discount) 
FROM orders 
WHERE sub_category 
IN ('Bookcases', 'Machines', 'Supplies', 'Tables') AND discount > 0
GROUP BY sub_category, category;
-- Discount range: Tables: 20%-50%, Bookcases: 15%-70%, Machines: 10%-70%, Supplies:20%

-- Total data in each bottom 4
SELECT sub_category, YEAR(order_date) year, COUNT(DISTINCT(order_id)) Total_order, COUNT(order_id) Total_data
FROM orders 
WHERE sub_category IN ('Bookcases', 'Machines', 'Supplies', 'Tables')
GROUP BY sub_category, year;
-- Around 20-100 orders, and around 20-110 datas each year.

select * from orders;

-- 09. LOSS ANALYSIS
-- loss records
SELECT * FROM orders WHERE profit < 0;

-- loss profits by years
SELECT YEAR(order_date) year, SUM(sales) total_sales, SUM(profit) total_profit 
FROM orders WHERE profit < 0 GROUP BY YEAR(order_date) ORDER BY YEAR(order_date);

-- Total loss profits
SELECT SUM(sales) total_sales, SUM(profit) total_profit 
FROM orders WHERE profit < 0;

SELECT SUM(sales) total_sales, SUM(profit) total_profit 
FROM orders WHERE profit < 0 AND sub_category in ('Machines', 'Supplies', 'Bookcases', 'Tables');
-- “All records that made a loss had a discount.


-- Total profit from discounted orders
SELECT SUM(sales) total_sales, SUM(profit) total_profit 
FROM orders WHERE discount > 0;
-- Net negative (-$34.590)

SELECT SUM(sales) total_sales, SUM(profit) total_profit 
FROM orders WHERE discount > 0 AND sub_category in ('Machines', 'Supplies', 'Bookcases', 'Tables');
-- Bottom 4 subcategories contribute to -$67.210
-- Not all discounted orders are unprofitable.


-- 10. KEY FINDINGS, CONCLUSIONS, RECOMMENDATIONS, and LIMITATIONS
-- Findings
-- Looking at the category, furniture in general has the lowest profit margin; it also has volatile profit margins and profit growth. 
-- By 2017, furniture has a minus yoy profit growth, with profit margin amounting to only 1.4%.
-- The furniture category consists of 4 subcategories: chairs, furnishing, bookcases, and tables, with 4Y avg profit margin of 8.1%, 14,24%, -3.02%, and -8.56%.
-- Having 2 of the bottom 4 subcategories, the profit margins are dragged down. 
-- Categories are spread evenly by sales but are dominated by technology and office supplies for profit. 

-- Looking at subcategories, tables, supplies, bookcases, and machines generally have the worst performance, with the lowest profit margin; tables, supplies, and bookcases generally operate at a loss.
-- By 2017, machines also started to operate at a loss. 
-- Four of these products have highly volatile profit margins, trending toward increasing losses. Collectively, these four products accounted for -13.4% of total profit in 2017.
-- Subcategories are spread quite unevenly by sales with top 5 subcategories contributing to about 50%, and unevenly by profit, where the top 3 subcategories contribute to about 50% of total profit in general. 
-- The top 3 subcategories contribute to 57.31% of total profit for 2017, mostly from copiers, showing an increasing trend in discrepancies.

-- Subcategories discounted vs non discounted orders showing nearly identical average quantity per item purchased.
-- Discount cuts the profit margin of subcategory products deeply, ranging from 11% to 58%; this makes some subcategories sell at a loss.

-- Conclusions
-- Category performance rank from the best: 1. Technology 2. Office Supplies 3. Furniture. 
-- Subcategory with best performer is Copiers, while the worst one is Tables.
-- Category sales are distributed evenly across all categories, while profits are dominated by technology and office supplies, with furniture only contributing to 6.44% of profit over 4 years.
-- Subcategory sales are distributed quite unevenly, and unevenly for profit.
-- Sales are growing healthily for each category(except 2015 for office supplies and technology). Profit also grow healthy, except for furniture(volatile profit growth).
-- The average quantity per record was similar between discounted vs non discounted purchase. But have a big negative impact on profit margin on each subcategories.
-- Discount is a major factor that causes the bottom 4 subcategories to operate at a loss, and have an overall negative impact towards the profitability on all subcategories.  
-- When most order and a high percentage of sales comes from discounted orders, and the base profit margin cannot cover the loss from discounted profit margin, then it's a loss.
-- For Tables, Bookcases, and Machines, most sales come from discounted orders, and because those discounts exceed the product's normal profit margin, every discounted sale is a guaranteed loss. 
-- Supplies has the same guaranteed-loss mechanic, but only needs a minority of sales discounted to drag it negative, because its baseline margin was already razor-thin.

-- Recommendations
-- 1. Stop discounting past the point of profitability. The total profit from all discounted orders is- $ 34,590, a net loss, with the bottom 4 subcategories contributing to -$67,211. 
-- Cap discount at no more than X%, below each product's own baseline margin. Note that the discount itself might be the signal for the customer to come, or 
-- the customer itself might be price sensitive; it's better to investigate or test pricing changes and find the best combination of both. 
-- 2. Some products are mostly sold when they're discounted, which might be an indication that the base price is too high already; try to run a controlled trial by lowering the price of a product
-- in the affected subcategory and compare the result of unit sales to the current discounted baseline while still keeping the margin healthy.
-- Caveat: It is recommended to test whether rec 1 or rec 2 perform better overall in terms of sales and profit before fully investing in it, as both are pricing strategies.
-- 3. If recommendations 1 and 2 don't work, and the product is unprofitable, then it's a signal to discontinue it.
-- 4. The Copiers and Accessories or others in top 5 subcategories account for a significant share of the company’s total profit which might be risky for the company if anything happen to those subcategories. 
-- Therefore, the company should closely monitor these subcategories and ensure that other business risks do not threaten their market position. At the same time, gradually diversifying into other 
-- subcategories or develop other subcategoris so it could help reduce the company’s reliance on these key profit contributors and provide greater resilience against potential disruptions.

-- Limitations
-- 1. Descriptive comparisons, not causation, product mix, customers, and timing can differ between discounted and non-discounted records. The analysis does not establish that discounts caused lower margins.
-- 2. Order-line grain, record-based discount share and average quantity are calculated per order line. The distinct-order KPI uses unique order IDs.
-- 3. No cost, shipping or return data, so it cannot tested whether operational these problems also add to the losses.
-- 4. Limited period and sample, findings describe the supplied Sample Superstore data for 2014–2017 and may not generalize to other businesses or periods. 
-- For example tables, bookcases, supplies and machines have only about 20–100 orders a year, so year-to-year changes are signals, not proof.


