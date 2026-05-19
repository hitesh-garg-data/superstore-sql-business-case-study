-- =========================================
-- SUPERSTORE ADVANCED SQL CASE STUDY
-- Analyst: Hitesh Garg
-- Objective:
-- Analyze revenue growth, profitability risks,
-- customer concentration, and volatility patterns.
-- =========================================

-- =========================================
-- EXECUTIVE REVENUE SUMMARY
-- Provide a high-level overview of overall business performance,
-- including total revenue, total profit, overall profit margin,
-- total orders, and number of unique customers.
-- This section serves as a quick snapshot for leadership.
-- =========================================

SELECT
	Round(SUM(sales),2) AS total_revenue,
	Round(SUM(profit),2) AS total_profit,
	ROUND(SUM(profit)/SUM(sales)*100,2) AS profit_margin,
	COUNT(DISTINCT order_id) AS total_orders,
	COUNT(DISTINCT customer_id) AS total_customers
FROM superstore_data;

-- Executive Insight:
-- The business generated approximately $2.30M in revenue and $286K in profit,
-- resulting in an overall profit margin of 12.47%. The dataset contains
-- 5,009 orders from 793 unique customers, indicating that repeat purchasing
-- behavior contributes significantly to overall revenue.

-- =========================================
-- MONTH-OVER-MONTH REVENUE GROWTH ANALYSIS
-- Calculate monthly revenue and compare it with the previous month
-- using the LAG() window function to identify growth or decline
-- in sales performance over time.
-- =========================================
With monthly_sales As (
	Select
		year (order_date) as year,
        Month (order_date) as month,
        Round(SUM(sales),2) AS revenue
	From superstore_data
    Group by
		year(order_date),
        Month(order_date)
	)
Select
	year,
    month,
    revenue,
    lag(revenue) over (order by year, month) as prev_month,
    Round(revenue- lag(revenue) over (order by year, month),2) as growth
From monthly_sales;

-- =========================================
-- ROLLING 3-MONTH REVENUE TREND
-- Smooth short-term fluctuations in monthly revenue by calculating
-- a rolling 3-month revenue total using a window frame.
-- This helps highlight broader sales trends.
-- =========================================
WITH monthly_sales AS (
    SELECT
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        Round(SUM(sales),0) AS monthly_revenue
    FROM superstore_data
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    year,
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY year, month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3_month_revenue
FROM monthly_sales;

-- =========================================
-- PROFIT MARGIN DETERIORATION DETECTION
-- Track monthly profit margin and compare it with the previous
-- month to detect periods where profitability is declining.
-- =========================================

WITH monthly_margin AS (
SELECT
	YEAR(order_date) AS year,
	MONTH(order_date) AS month,
	Round(SUM(profit)/SUM(sales)*100,2) AS margin
FROM superstore_data
GROUP BY 
	YEAR(order_date), 
    MONTH(order_date)
)
SELECT
	year,
	month,
	margin,
	LAG(margin) OVER (ORDER BY year,month) AS prev_margin,
	Round(margin - LAG(margin) OVER (ORDER BY year,month) ,2) AS margin_change
FROM monthly_margin;

-- =========================================
-- SEGMENT PROFITABILITY ANALYSIS
-- Evaluate performance of different customer segments by comparing
-- revenue contribution, profit generation, and profit margin.
-- =========================================

SELECT
	segment,
	Round(SUM(sales),2) AS revenue,
	Round(SUM(profit),2) AS profit,
	ROUND(SUM(profit)/SUM(sales)*100,2) AS margin
FROM superstore_data
GROUP BY segment
ORDER BY margin DESC;

-- Segment Insight:
-- The Home Office segment generates the highest profit margin (14.05%),
-- indicating stronger profitability per sale compared to other segments.
-- Although the Consumer segment contributes the highest revenue, its
-- margin is the lowest (11.55%), suggesting potential pricing pressure
-- or higher discount levels in consumer-focused sales.

-- =========================================
-- CUSTOMER REVENUE CONCENTRATION (PARETO ANALYSIS)
-- Measure how revenue is distributed across customers and determine
-- whether a small group of customers contributes a large portion of
-- total revenue.
-- =========================================
With customer_sales As(
	Select
		customer_id,
        Round(sum(sales),2) as revenue
	From superstore_data
    Group by customer_id
    )
Select
	customer_id,
    revenue,
    Round(Sum(revenue) Over (order by revenue desc)/
    Sum(revenue) Over () *100 ,2) AS cumulative_revenue_pct
FROM customer_sales;

-- Pareto Insight:
-- Revenue contribution is widely distributed across customers.
-- The highest-revenue customer contributes only around 1% of
-- total sales, indicating low customer concentration. This suggests
-- the business is resilient to customer churn because revenue is
-- not dependent on a small number of high-value clients.

-- =========================================
-- PARETO ANALYSIS (80/20 RULE)
-- Identify how many customers generate
-- 80% of total business revenue.
-- This helps measure customer concentration
-- and dependency risk.
-- =========================================

WITH customer_sales AS(
	SELECT
		customer_id,
		SUM(sales) AS revenue
	FROM superstore_data
	GROUP BY customer_id
),

pareto AS(
	SELECT
		customer_id,
		revenue,
		SUM(revenue) OVER (ORDER BY revenue DESC) /
		SUM(revenue) OVER () AS cumulative_revenue_pct
	FROM customer_sales
)

SELECT	
	COUNT(customer_id) AS total_customers,
	SUM(
		CASE
			WHEN cumulative_revenue_pct <= 0.80 THEN 1
			ELSE 0
		END
	) AS customers_contributing_80pct_revenue
FROM pareto;

-- Result: 395 of 793 customers (~50%) generate 80% of total revenue.

-- Pareto Insight:
-- Revenue contribution is relatively diversified across the customer base.
-- Approximately half of the customers generate 80% of total revenue,
-- which indicates a lower customer concentration risk compared to
-- businesses that follow a strict 80/20 Pareto distribution.
		

-- =========================================
-- REVENUE VOLATILITY ANALYSIS
-- Measure how stable monthly revenue is by calculating the
-- standard deviation of revenue across all months.
-- =========================================

With monthly_sales As(
	select
		Year(order_date) as year,
        Month(order_date) as month,
        Round(Sum(sales),2) as revenue
	From superstore_data
    Group by 
		Year(order_date), 
        Month(order_date)
	Order by 
		year,
        month
    )
Select
	year,
    month,
    revenue,
    Round(stddev(revenue) over(),2) as revenue_volatility
    from monthly_sales;

-- =========================================
-- ROLLING REVENUE VOLATILITY
-- Calculate short-term revenue variability using a rolling
-- three-month standard deviation window.
-- =========================================

With monthly_sales As(
	select
		Year(order_date) as year,
        Month(order_date) as month,
        Round(Sum(sales),2) as revenue
	From superstore_data
    Group by 
		Year(order_date), 
        Month(order_date)
	Order by 
		year,
        month
    )
Select
	year,
    month,
    revenue,
    Round(stddev(revenue) over(
				order by year, month
				ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) as rolling_revenue_volatility
    from monthly_sales;

-- =========================================
-- LOGISTICS PERFORMANCE ANALYSIS
-- Evaluate delivery efficiency by calculating the average
-- shipping time for each region using the difference between
-- order date and shipping date.
-- =========================================
Select
	region,
	Round(Avg(Datediff(ship_date, order_date)),2) as avg_shipping_days
From superstore_data
Group by region
Order by avg_shipping_days ASC;

-- Logistics Insight:
-- The East region demonstrates the fastest average shipping time
-- at approximately 3.91 days, indicating relatively efficient
-- logistics operations. The Central region shows the slowest
-- delivery performance at 4.06 days, which may indicate
-- logistical inefficiencies or longer transportation distances.

-- =========================================
-- DATA INTEGRITY VALIDATION
-- Verify that critical columns such as profit contain no
-- missing values that could distort profitability analysis.
-- =========================================

Select
	count(*),
    count(*) - count(profit) as missing_profit
From superstore_data;
    
-- Data Integrity Insight:
-- The dataset contains 9,993 transaction records with no missing
-- values in the profit column, indicating that profitability
-- analysis can be performed without requiring additional data
-- cleaning or imputation.