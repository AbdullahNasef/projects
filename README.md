# 📊 E-Commerce Sales Data Engineering & Analytics

## 📝 Project Overview
This project transforms a raw dataset of over **500,000 retail transactions** into a structured, high-performance analytical database. Using **Advanced T-SQL**, I performed data cleaning, established a **Star Schema**, and derived complex business insights to support decision-making.

## 🚀 Key Features
- **Data Cleaning:** Handled nulls, corrected data types, and filtered non-commercial transactions (Damages, Postage, etc.).
- **Data Modeling:** Designed a Star Schema consisting of `Fact_sales`, `Dim_Products`, and `Dim_Customers`.
- **Advanced Analytics:** Implemented Month-over-Month (MoM) Growth analysis and Product Ranking using **Window Functions** (`LAG`, `DENSE_RANK`, `NTILE`).
- **Optimization:** Created reusable SQL **Views** for seamless Power BI integration.

## 🛠️ Tools Used
- **SQL Server (T-SQL)**: Core data processing and analysis.
- **Power BI**: (Upcoming) Data visualization and Dashboarding.

## 📂 Repository Structure
- `SQL_Scripts/`: Contains the cleaning and modeling scripts.
- `Analysis_Queries/`: Advanced analytical queries and growth calculations.

- ## 🔮 Future Roadmap (Automation)
I am currently developing a **Python Automation Script** to further enhance the project lifecycle:
- **Scheduled Reporting:** Automate SQL query execution and report generation.
- **Multi-Channel Distribution:** Automatically send key insights and PDF reports via **Email** and **WhatsApp** (using libraries like `smtplib` and `pywhatkit`).
- **Dynamic Alerts:** Trigger notifications when specific KPIs (like a sales drop) are detected.
