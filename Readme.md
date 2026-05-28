# HOSPITAL PATIENTS RECORD ANALYSIS 
An integrated data framework for optimizing clinical operations, patient tracking, and healthcare financial performance using SQL database queries and Power BI visual analytics.

## PROJECT PROBLEM STATEMENT

Modern healthcare facilities generate substantial volumes of administrative, clinical, and financial records daily. When these data points remain confined to isolated spreadsheets or flat files, cross-referencing information becomes an operational challenge and without a centralized reporting framework, healthcare administrators face distinct operational difficulties such as:

* Inconsistent Patient Tracking
* Unbalanced Resource Allocation
* Complex Financial Auditing

  ### The Solution:
A unified database framework was implemented to clean, structure, and aggregate raw hospital records. This data architecture was subsequently integrated with an interactive Power BI dashboard, providing stakeholders with clear visibility into patient volumes, geographic trends, and total treatment revenues to support data-driven institutional choices.


## TOOLS UTILIZED

* SQLite: Utilized as the relational database engine to store the datasets, execute SQL queries, clean records, and apply conditional data segmentation logic.
* Power BI: Employed to design the data model relationships, wireframe the report layout, and build the interactive executive dashboard for stakeholder review.
* Microsoft PowerPoint: Used for the initial architecture design.
  

## DATASET SOURCE AND STRUCTURE OVERVIEW

This healthcare dataset sourced directly from [Kaggle](https://www.kaggle.com/datasets/ahmedezzatibrahem/hospital-patient-records) comprises comprehensive clinical, administrative, and financial records structured to evaluate hospital operational efficiency, healthcare delivery, and revenue workflows  and the data are organized across five core relational tables:

* `patients`: Contains patient demographics, registration timelines, and health insurance details.
* `payers`: Insurance provider networks, coverage limits, and policy classifications
* `appointments`: Tracks individual patient visits, encounter schedules, and checkout statuses.
* `treatments`: Captures administered medical procedures, clinical interventions, and their associated operational costs.
* `billing`: Records transactional history, payment methods, outstanding balances, and financial status details.


## DATABASE SCHEMA AND ARCHITECTURE

The hospital database consists of a relational schema designed to store and connect clinical, administrative, and financial datasets. The structure is built around five core tables:

* `patient_summary`: Contains patient demographics, location details, and basic physiological data.
* `appointment_summary`: Tracks individual encounter IDs, appointment dates, locations, and assigned doctors.
* `treatment_summary`: Details the medical procedures administered, treatment names, and associated operational costs.
* `payer_summary`: Monitors insurance claim amounts, total covered costs, and payer network details.
* `revenue_summary`: Consolidates monthly financial records, total encounter volumes, and average revenue per visit.

## Enhanced Entity-Relationship (EER) Diagram

![EER Diagram](images/EER%20Diagram.jpg)




