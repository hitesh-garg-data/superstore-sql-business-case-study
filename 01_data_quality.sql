-- =========================================
-- SUPERSTORE DATA QUALITY ANALYSIS
-- Dataset validation and anomaly detection
-- Purpose: Verify dataset integrity before performing business analysis.
-- =========================================

-- =========================================
-- DATE COMPONENT EXTRACTION
-- Extract individual date components from order_date
-- to confirm correct date formatting and enable
-- time-based analysis such as monthly or quarterly trends.
-- =========================================

Select
	order_id,
    order_date,
    Year(order_date) as order_year,
    Month(order_date) as order_month,
    Quarter(order_date) as order_quarter,
    day(order_date) as order_day
From
	superstore_data
limit 20;

-- =========================================
-- ORDER LEVEL DUPLICATE CHECK
-- Identify order_ids that appear multiple times.
-- This is expected because the dataset is recorded
-- at the order-line level where each product within
-- an order is stored as a separate row.
-- =========================================

Select
	order_id,
    Count(*) as duplicate_count
From
	superstore_data
Group by
	order_id
Having Count(*) > 1;

-- NOTE:
-- Multiple rows per order_id are expected because the dataset
-- is recorded at the order-line level, where each row represents
-- a product purchased within an order. Therefore these are not
-- true duplicates and should not be removed.
 
-- =========================================
-- ORDER + PRODUCT DUPLICATE CHECK
-- Verify whether the same product appears multiple times
-- within a single order. These cases may represent legitimate
-- multi-line purchases or potential duplicate records.
-- =========================================

SELECT
	order_id,
	product_id,
COUNT(*) AS duplicate_count
FROM superstore_data
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

-- =========================================
-- EXACT TRANSACTION DUPLICATE DETECTION
-- Check whether completely identical rows exist
-- based on key transactional attributes.
-- If count > 1, it indicates true duplicate records.
-- =========================================

SELECT
	order_id,
	product_id,
	sales,
	quantity,
	discount,
	profit,
	COUNT(*) AS duplicate_count
FROM superstore_data
GROUP BY
	order_id,
	product_id,
	sales,
	quantity,
	discount,
	profit
HAVING COUNT(*) > 1;

-- =========================================
-- COUNT TRUE DUPLICATE TRANSACTIONS
-- Determine the total number of duplicated rows
-- detected in the dataset.
-- =========================================

SELECT COUNT(*)
FROM (
    SELECT
        order_id,
        product_id,
        sales,
        quantity,
        discount,
        profit,
        COUNT(*) AS duplicate_count
    FROM superstore_data
    GROUP BY
        order_id,
        product_id,
        sales,
        quantity,
        discount,
        profit
    HAVING COUNT(*) > 1
) t;

-- =========================================
-- DUPLICATE REMOVAL
-- Remove exact duplicate transactions while
-- retaining the first occurrence of each record.
-- Window function ROW_NUMBER() is used to identify
-- duplicates safely.
-- =========================================

SET SQL_SAFE_UPDATES = 0;

DELETE FROM superstore_data
WHERE row_id NOT IN (
    SELECT row_id
    FROM (
        SELECT
            row_id,
            ROW_NUMBER() OVER(
                PARTITION BY
                    order_id,
                    product_id,
                    sales,
                    quantity,
                    discount,
                    profit
                ORDER BY row_id
            ) AS rn
        FROM superstore_data
    ) t
    WHERE rn = 1
);

SET SQL_SAFE_UPDATES = 1;

-- =========================================
-- NULL HANDLING IN PROFIT CALCULATIONS
-- COALESCE replaces NULL profit values with 0
-- to ensure aggregate calculations remain valid.
-- =========================================

Select
	product_name,
	Round(Sum(coalesce(profit,0)),2) as safe_profit
FROM superstore_data
GROUP BY product_name
ORDER BY safe_profit DESC;

-- =========================================
-- IDENTIFY MISSING PROFIT VALUES
-- Detect rows where profit is NULL which could
-- affect profitability calculations.
-- =========================================

SELECT *
FROM superstore_data
WHERE profit IS NULL;

-- =========================================
-- NEGATIVE MARGIN TRANSACTIONS
-- Identify transactions where profit is negative.
-- These may indicate excessive discounts,
-- shipping costs, or pricing inefficiencies.
-- =========================================

SELECT
    order_id,
    product_name,
    sales,
    profit,
    ROUND((profit / sales) * 100,2) AS profit_margin
FROM superstore_data
WHERE profit < 0
ORDER BY profit ASC
LIMIT 20;

-- =========================================
-- LOSS-MAKING PRODUCTS
-- Identify products whose total profit across
-- all transactions is negative.
-- =========================================

SELECT
    product_name,
    Round(SUM(profit),2) AS total_profit
FROM superstore_data
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- =========================================
-- TIME SERIES COMPLETENESS CHECK
-- Verify that orders exist across all months.
-- Missing months may indicate incomplete data.
-- =========================================

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    COUNT(*) AS orders
FROM superstore_data
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- =========================================
-- OUTLIER DETECTION (TOP 1% SALES)
-- Calculate the approximate 99th percentile
-- sales value using PERCENT_RANK().
-- =========================================

Select
	Min(sales) as percentile_99
From (
	Select
		sales,
        percent_rank() over (order by sales) as pct_rank
	From superstore_data
	)t
Where pct_rank >= 0.99;

-- The 99th percentile sales value is approximately 2504.74.
-- This means only the top 1% of transactions have sales greater than
-- this threshold. These transactions can be considered outliers and
-- may represent bulk purchases, high-value products, or unusually
-- large orders compared to the rest of the dataset.


-- Retrieve all transactions belonging to the top 1% sales bracket.

SELECT sales
FROM (
    SELECT
        sales,
        PERCENT_RANK() OVER (ORDER BY sales) AS pct_rank
    FROM superstore_data
) t
WHERE pct_rank >= 0.99;

-- =========================================
-- DATASET HEALTH SUMMARY
-- Provide a quick audit of dataset completeness
-- including row counts and missing values.
-- =========================================

Select
	Count(*) As total_rows,
    Count(Distinct order_id) As unique_orders,
    Count(*) - Count(order_date) As missing_dates,
    Count(*) - Count(profit) as missing_profit
From superstore_data;

-- Dataset audit shows 9,993 transaction rows representing 5,009 unique orders.
-- No missing values were found in the order_date or profit columns,
-- indicating the dataset is structurally complete for time-based and
-- profitability analysis.

-- The difference between total rows and unique orders confirms that the
-- dataset is recorded at the order-line level, where each row represents
-- a product within an order rather than a single order summary.

-- Multiple rows per order_id are expected because a single order may
-- contain multiple products. Therefore the dataset granularity is
-- at the order-line level rather than the order level.