# 📘 Superstore Advanced SQL Case Study

Advanced SQL business analysis project focused on revenue growth, profitability risks, customer concentration, operational efficiency, and data integrity using the Superstore dataset.

This project demonstrates practical SQL analysis using:
- CTEs
- Window Functions
- Rolling Calculations
- Ranking Functions
- Pareto Analysis
- Data Validation
- Business Insight Generation

---

# 🎯 Business Objective

The objective of this case study is to analyze:

- Revenue growth trends
- Profitability deterioration
- Customer concentration risk
- Revenue volatility
- Logistics efficiency
- Dataset reliability

The analysis focuses on identifying operational and financial risks using historical transactional data.

---

# 🧰 Tools & Skills Used

- SQL (MySQL)
- CTEs
- Window Functions
- Aggregations
- Rolling Metrics
- Ranking Functions
- Business Performance Analysis
- Data Quality Validation

---

# 📂 Project Structure

```text
superstore-advanced-sql-case-study/
│
├── README.md
│
├── dataset/
│   └── superstore_dataset.csv
│
├── sql_queries/
│   ├── 01_data_quality.sql
│   ├── 02_superstore_sales_analysis.sql
│   └── 03_superstore_case_study.sql
│
├── screenshots/
│   ├── Executive_Revenue_Summary.png
│   ├── Profit_margin_by_segments.png
│   ├── Revenue_vs_profit_by_region.png
│   ├── Top10_loss_making_products.png
│   ├── Window_functions_products_ranking_by_region.png
│   ├── Least_profitable_months.png
│   ├── Shipping_Time_by_Ship_Mode.png
│   └── Combine_Data_Quality_Checks.png
```

---

# 📌 Key Business Questions Solved

### Revenue & Growth
- Is revenue growing consistently over time?
- Which months show strongest and weakest performance?
- Is growth translating into profitability?

### Profitability Risk
- Which customer segments have weak margins?
- Which products consistently generate losses?
- Are margins deteriorating over time?

### Customer Concentration
- Is revenue dependent on a small group of customers?
- How diversified is the customer base?

### Logistics & Operations
- Which regions or shipping modes show inefficiencies?
- Is delivery performance stable?

### Data Reliability
- Does the dataset contain duplicates or missing values?
- Can profitability analysis be trusted?

---

# 📊 Featured Analysis

## 1. Executive Revenue Summary

High-level KPI overview including:
- Total Revenue
- Total Profit
- Profit Margin
- Total Orders
- Unique Customers

![Executive Revenue Summary](screenshots/Executive_Revenue_Summary.png)

---

## 2. Product Ranking Using Window Functions

Advanced ranking analysis using:
- `RANK()`
- `ROW_NUMBER()`
- `PARTITION BY`
- `OVER()`

Used to identify top-performing products across regions.

![Window Function Ranking](screenshots/Window_functions_products_ranking_by_region.png)

---

# 🔍 Major Insights

- Revenue growth does not always translate into profit growth.
- Consumer segment drives strong revenue but weaker margins.
- Customer revenue concentration risk is relatively low.
- Certain products generate consistent losses despite strong sales.
- Profitability varies significantly across regions and segments.
- Dataset integrity checks confirmed no major missing-value issues.

---

# ⚠️ Scope & Limitations

This project focuses on descriptive SQL analysis using historical transactional data.

It does not include:
- Forecasting
- Machine Learning
- Predictive Modeling
- Prescriptive Optimization

---

# 📈 SQL Concepts Demonstrated

## Intermediate SQL
- GROUP BY
- HAVING
- CASE WHEN
- JOINS
- Subqueries

## Advanced SQL
- CTEs
- Window Functions
- LAG()
- Rolling Calculations
- Ranking Functions
- Pareto Analysis
- Percentile Analysis

---

# 👨‍💻 Author

**Hitesh Garg**

Data Analyst | SQL • Power BI • Excel • Python • Finance Analytics

---

# 🔗 Connect

- GitHub: https://github.com/hitesh-garg-data
- Portfolio: (https://www.notion.so/Portfolio-Hitesh-Garg-Finance-Business-Data-Analyst-2a9e7a66bd4380e1904acef1d5f325d3)
