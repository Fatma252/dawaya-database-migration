# Dawaya Pharmacy — Relational Database Migration & Analytics

## Project Overview
This project migrates **Dawaya Pharmacy's** historical flat-file sales spreadsheet (`flat_sales_export.csv`) into a normalized **Third Normal Form (3NF)** PostgreSQL relational database. The solution eliminates data redundancy, resolves manual update/insertion anomalies, enforces referential integrity, and provides SQL-driven business intelligence across all 7 pharmacy branches.

## Repository Structure

```text
dawaya_project_deliverables/
├── scripts/
│   ├── schema.sql                                  # 3NF DDL schema (tables, PKs, FKs, CHECK constraints)
│   ├── seed.sql                                    # Data cleaning, deduplication & migration script
│   └── queries.sql                                 # 10 analytical SQL queries (filtering, aggregation, joins)
├── docs/
│   ├── Dawaya_Database_Architecture_and_Insights.pdf  # Executive report (RDBMS justification, ERD, 3NF & insights)
│   ├── data_dictionary.md                          # Source schema documentation and data quality notes
│   └── business_questions.md                       # Business questions with SQL solutions & insights
├── data/
│   └── flat_sales_export.csv                       # Raw Q3 2026 transactional export (573 rows)
└── README.md