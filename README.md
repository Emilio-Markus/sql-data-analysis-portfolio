# SQL Data Analytics Portfolio Project

## Retail Sales Analytics – End-to-End SQL Project

This project demonstrates a complete data analytics workflow using SQL Server, covering database design, data preparation, exploratory analysis, business analytics, and advanced SQL techniques.

The goal of this project is to simulate how a data analyst would work with a retail sales dataset to extract business insights that support decision-making.

The project includes database creation, data validation, analytical queries, reusable reporting views, and stored procedures for operational reporting.

---

# Project Objectives

The objective of this project is to demonstrate proficiency in:

- SQL database design  
- Data validation and cleaning  
- Exploratory data analysis  
- Business-focused analytics  
- Advanced SQL techniques  
- Reusable reporting logic  

This project simulates a retail business environment where sales data is analyzed to understand customer behavior, product performance, and revenue trends.

---

# Technologies Used

- SQL Server  
- SQL Server Management Studio (SSMS)  
- GitHub  
- T-SQL  

### Key SQL techniques demonstrated include:

- Joins  
- Aggregations  
- Common Table Expressions (CTEs)  
- Window Functions  
- Views  
- Stored Procedures  
- Data Quality Checks  

---

# Project Structure


SQL-Data-Analytics-Portfolio
│
├── sql
│ ├── 01_create_database.sql
│ ├── 02_create_tables.sql
│ ├── 03_insert_data.sql
│ ├── 04_data_cleaning.sql
│ ├── 05_exploratory_queries.sql
│ ├── 06_business_analysis.sql
│ ├── 07_cte_window_functions.sql
│ ├── 08_views.sql
│ └── 09_stored_procedures.sql
│
├── docs
│ ├── 01_Project_Overview.md
│ ├── 02_Business_Questions.md
│ ├── 03_Database_Design.md
│ ├── 04_Data_Cleaning_Report.md
│ └── 05_Insights_Report.md
│
└── README.md


---

# Database Design

The project models a simplified retail sales environment with the following tables:

### Customers
Stores customer information including contact details and location.

### Categories
Product groupings used for reporting and analysis.

### Products
Product catalog including price, cost, and category.

### Orders
Customer purchases including order date, status, and total value.

### Order_Items
Line-level order details including quantity and selling price.

### Payments
Records payment transactions for orders.

---

# Data Analytics Workflow

This project follows a structured analytics process.

---

## 1. Database Creation

The database and schema are created using:


01_create_database.sql
02_create_tables.sql


These scripts define all tables and relationships required for the retail dataset.

---

## 2. Data Loading

Sample data is inserted into the tables using:


03_insert_data.sql


This creates a realistic dataset for analysis.

---

## 3. Data Cleaning and Validation

Data quality checks are performed to identify issues such as:

- Missing values  
- Duplicate records  
- Orphan records  
- Inconsistent order totals  
- Status inconsistencies  

Script used:


04_data_cleaning.sql


---

## 4. Exploratory Data Analysis

Exploratory queries are used to understand the dataset and identify patterns.

Examples include:

- Customer distribution  
- Product distribution  
- Payment method usage  
- Order activity  

Script used:


05_exploratory_queries.sql


---

## 5. Business Analytics

Business-focused queries analyze performance across several dimensions.

Examples include:

- Top customers by revenue  
- Product revenue and profit  
- Category performance  
- Revenue trends  
- Customer lifetime value  

Script used:


06_business_analysis.sql


---

## 6. Advanced SQL Analysis

Advanced SQL techniques are used to extract deeper insights.

These include:

- Ranking customers by revenue  
- Product ranking within categories  
- Running revenue totals  
- Customer purchase intervals  
- Revenue contribution analysis  

Script used:


07_cte_window_functions.sql


---

## 7. Reporting Views

Reusable views are created to support reporting and dashboards.

Examples include:

- Customer order summary  
- Product performance  
- Category performance  
- Monthly revenue  
- Detailed order reporting  

Script used:


08_views.sql


---

## 8. Stored Procedures

Stored procedures are implemented to create reusable analytical queries.

Examples include:

- Retrieving top customers  
- Sales within a date range  
- Category performance reports  
- Customer order history  
- Product performance reports  

Script used:


09_stored_procedures.sql


---

# Example Business Questions Answered

This project answers important business questions such as:

- Which customers generate the most revenue?  
- Which products are the most profitable?  
- Which categories contribute the most to total sales?  
- What are the monthly sales trends?  
- Which products have high margins but low sales volume?  
- Which cities generate the most revenue?  

---

# Key Insights (Example)

Analysis of the dataset can reveal insights such as:

- Revenue concentration among top customers  
- High-margin products with growth potential  
- Category performance differences  
- Customer purchasing patterns  
- Sales trends over time  

These insights can help guide business strategy, marketing efforts, and inventory planning.

---

# Skills Demonstrated

This project demonstrates several core data analyst skills:

### Data Modeling
Designing relational databases for business datasets.

### Data Quality Assurance
Validating and cleaning datasets before analysis.

### SQL Analytics
Performing complex analytical queries.

### Advanced SQL
Using window functions, CTEs, and ranking techniques.

### Reporting Layer Design
Creating views and stored procedures for reporting.

---

# How to Run the Project

1. Open **SQL Server Management Studio**
2. Execute scripts in the following order:


01_create_database.sql
02_create_tables.sql
03_insert_data.sql
04_data_cleaning.sql
05_exploratory_queries.sql
06_business_analysis.sql
07_cte_window_functions.sql
08_views.sql
09_stored_procedures.sql


---

# Future Improvements

Possible enhancements include:

- Integration with Power BI dashboards  
- Larger datasets for scalability testing  
- Automated ETL pipelines  
- Additional stored procedures for reporting  
- Predictive analytics models  

---

# Author

**Emilio Markus**

Aspiring Data Analyst with a background in financial systems and SQL analytics.

This project was created as part of a professional portfolio demonstrating SQL analytics capabilities.

---

# Portfolio Purpose

This project demonstrates practical SQL skills used in real-world data analytics workflows and showcases the ability to transform raw data into meaningful business insights.
