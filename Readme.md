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


## DATA EXPLORATION AND ANALYSIS

To uncover business insights from the hospital database, structured SQLite queries were developed across core transactional tracks: Patient Demographics, Operational Load, Performance Metrics, and View Materialization for downstream BI consumption.

### 1. Patient Demographics 
These queries baseline the distinct patient population size, break down gender distribution, evaluate segmented age cohorts, and isolate retention dynamics between one-time and repeat visitors.
```sql
-- Total Patient Volume Baseline
SELECT COUNT(*) as total_patients
FROM patients;

-- Gender Distribution Analysis
SELECT gender, COUNT(*) AS total
FROM patients
GROUP BY gender; 

-- Demographic Age Tier Segmentation
SELECT 
  CASE 
    WHEN (strftime('%Y', 'now') - strftime('%Y', birthdate)) < 18 THEN 'Under 18'
    WHEN (strftime('%Y', 'now') - strftime('%Y', birthdate)) BETWEEN 18 AND 35 THEN '18-35'
    WHEN (strftime('%Y', 'now') - strftime('%Y', birthdate)) BETWEEN 36 AND 50 THEN '36-50'
    WHEN (strftime('%Y', 'now') - strftime('%Y', birthdate)) BETWEEN 51 AND 65 THEN '51-65'
    ELSE 'Above 65'
  END AS age_group,
  COUNT(*) AS total
FROM patients
GROUP BY age_group;

-- Patient Retention: One-Time vs. Repeat Encounters
SELECT 
  CASE 
    WHEN visit_count = 1 THEN 'One-time Patient'
    ELSE 'Repeat Patient'
  END AS patient_type,
  COUNT(*) AS total
FROM (
  SELECT patient, COUNT(*) AS visit_count
  FROM encounters
  GROUP BY patient
)
GROUP BY patient_type;

```

### 2. Clinical Operations & Encounter Volume Metrics

These queries analyze the hospital's service load by measuring encounter volume patterns over time, tracking top primary diagnosis drivers, ranking facility operational loads, and breaking down encounter classes.

```sql
-- Total Logged Hospital Encounters
SELECT COUNT(*) AS total_encounters
FROM encounters;

-- Operational Load Trends Over Time
SELECT
   strftime('%Y' , start) AS year,
   COUNT(*) AS total_encounters
 FROM encounters
 GROUP BY year
 ORDER BY year;

-- Top 10 Primary Healthcare Encounter Reasons
SELECT reasondescriptio, COUNT(*) AS total
FROM encounters
WHERE reasondescriptio IS NOT NULL
GROUP BY reasondescriptio
ORDER BY total DESC
LIMIT 10;

-- Top 10 Facilities by Encounter Throughput
SELECT organization, COUNT(*) AS total_encounters
FROM encounters
GROUP BY organization
ORDER BY total_encounters DESC
LIMIT 10;

-- Distribution of Encounter Class Classifications
SELECT encounterclass, COUNT(*) AS total
FROM encounters
GROUP BY encounterclass
ORDER BY total DESC;

```

### 3. Treatment Costs & Financial Impact Analysis

These queries review resource costs, tracking procedure volume drivers, checking baseline average clinical treatment costs, and looking at financial expenditures by fiscal year.

```sql
-- Top 10 Administered Clinical Procedures
SELECT description, COUNT(*) AS total
FROM procedures
GROUP BY description
ORDER BY total DESC
LIMIT 10;

-- Average Base Cost of Treatments
SELECT AVG(base_cost) AS avg_treatment_cost
FROM procedures;

-- Total Procedure Expenditures Over Time
SELECT strftime('%Y', start) AS year,
       SUM(base_cost) AS total_cost
FROM procedures
GROUP BY year
ORDER BY year;

```

### 4. Revenue Lifecycle, Payer Networks & Patient Value

This set breaks down the hospital's overall revenue streams, reviews payer performance, and profiles the relationship between visit counts and total financial contributions.

```sql
-- Total Gross Claims Revenue Generated
SELECT SUM(total_claim_cost) AS total_revenue
FROM encounters;                    

-- Revenue Performance Trends Over Time
SELECT strftime('%Y', start) AS year,
       SUM(total_claim_cost) AS total_revenue
FROM encounters
GROUP BY year
ORDER BY year;                  

-- Payer Network Performance and Market Revenue Share
SELECT payer, COUNT(*) AS total_encounters,
       SUM(total_claim_cost) AS total_revenue
FROM encounters
GROUP BY payer
ORDER BY total_revenue DESC;              

-- Top 10 High-Value Patient Portfolios
SELECT patient, 
       SUM(total_claim_cost) AS total_spent
FROM encounters
GROUP BY patient
ORDER BY total_spent DESC
LIMIT 10;

-- Patient Lifetime Value (LTV) Distribution
SELECT e.patient,
       COUNT(e.id) AS total_visits,
       SUM(e.total_claim_cost) AS lifetime_value
FROM encounters e
GROUP BY e.patient
ORDER BY lifetime_value DESC
LIMIT 10;

-- Correlation Analysis: Encounter Frequency vs. Financial Contribution
SELECT e.patient,
       COUNT(e.id) AS total_visits,
       SUM(e.total_claim_cost) AS total_spent,
       ROUND(SUM(e.total_claim_cost) / COUNT(e.id), 2) AS avg_spent_per_visit
FROM encounters e
GROUP BY e.patient
ORDER BY total_visits DESC
LIMIT 10;

```

### 5. Summary Table Optimization (ETL Layer for Power BI)

To optimize data model connections and reporting performance inside Power BI, clean summary staging tables were created directly within SQLite to separate dimensions from fact values.

```sql
-- Patient Portfolio Dimension Table
CREATE TABLE patient_summary AS
SELECT 
  p.id,
  p.first,
  p.last,
  p.gender,
  p.race,
  p.ethnicity,
  strftime('%Y', 'now') - strftime('%Y', p.birthdate) AS age,
  p.city,
  p.state,
  COUNT(e.id) AS total_visits,
  SUM(e.total_claim_cost) AS total_spent
FROM patients p
LEFT JOIN encounters e ON p.id = e.patient
GROUP BY p.id;

-- Encounter & Appointment Scheduling Fact Table
CREATE TABLE appointment_summary AS
SELECT 
  e.id,
  e.start,
  e.stop,
  e.patient,
  e.organization,
  e.payer,
  e.encounterclass,
  e.description,
  e.total_claim_cost,
  e.payer_coverage,
  e.reasondescriptio
FROM encounters e;

-- Clinical Intervention & Treatment Fact Table
CREATE TABLE treatment_summary AS
SELECT 
  p.patient,
  p.encounter,
  p.description AS procedure_name,
  p.base_cost,
  p.reasondescriptio AS reason,
  strftime('%Y', p.start) AS year
FROM procedures p;

-- Claims, Financial Status, and Revenue Fact Table
CREATE TABLE revenue_summary AS
SELECT 
  e.patient,
  e.payer,
  e.organization,
  strftime('%Y', e.start) AS year,
  e.total_claim_cost,
  e.payer_coverage,
  e.total_claim_cost - e.payer_coverage AS out_of_pocket,
  CASE 
    WHEN e.payer_coverage > 0 THEN 'Paid'
    ELSE 'Pending'
  END AS payment_status
FROM encounters e;

-- Facility and Healthcare Center Performance Table
CREATE TABLE organization_summary AS
SELECT 
  o.id,
  o.name,
  o.city,
  o.state,
  COUNT(e.id) AS total_encounters,
  SUM(e.total_claim_cost) AS total_revenue
FROM organizations o
LEFT JOIN encounters e ON o.id = e.organization
GROUP BY o.id;

```



## DASHBOARD REPORT

* Executive Key Metrics (KPI Cards): High-level tracking for **Total Patients (974), Total Appointments (28K), Total Revenue ($67.89M), and Average Treatment Cost ($2.21K).
  
* Demographics & Patient Profiles: Age Distribution and separating, Repeat vs. New Patient, Gender Distribution.
  
* Financial & Revenue Workflows:Paid vs. Pending Bills,Top Patients by Revenue and Top Payers by Revenue.
  
* Clinical Operations & Cost Dynamics:Most Common Treatments and Top Organizations by Encounter Volume,Encounter Trends Over Time and Total Treatment Cost Over Time and Patient Cost vs. Insurance Coverage.
  
* Interactive Slicers: A left-hand filtering panel allowing stakeholders to dynamically slice the entire dashboard by Year, Gender, Race, and Payment Status.

### Interactive Interface Preview

![Dashboard Design](images/Dashboard%20Design.jpg)

## KEY INSIGHTS AND RECCOMENDATIONS

* Payer Metrics & Revenue Risk: A massive portion of the hospital’s $67.89M total revenue** is categorized under "No Insurance", closely followed by Medicare. This presents a high risk for pending balances. The facility should implement pre-admission financial counseling and optimized installment payment workflows to mitigate outstanding debt.

* Patient Retention Dynamics: The dashboard highlights a significant volume of Repeat Patients compared to new ones. To maximize patient lifetime value, the hospital should establish structured patient-relationship management tracks and follow-up clinical pathways.
  
* Operational Bottlenecks & Capacity Planning: Facility utilization and encounter counts are dominated by a few top organizations. Resources, staff scheduling, and medical equipment allocation should be dynamically adjusted to mirror these high-load centers, preventing operational burnout and reducing patient wait times.
  
* Treatment Cost Management: With an Average Treatment Cost of $2.21K, a clear gap exists where patient costs consistently outpace insurance coverage limits. Introducing transparent pricing structures and specialized care packages can help reduce the out-of-pocket financial burden on patients while safeguarding hospital profit margins.


## PROJECT ARCHITECTURE & WORKFLOW

The implementation of this project follows a structured, end-to-end data analytics lifecycle, transitioning from raw data storage to interactive business intelligence reporting:

1. Data Ingestion & Environment Setup: Imported the raw clinical datasets into an optimized relational database environment using SQLite.

2. Database Modeling: Designed the primary keys, foreign keys, and structural table relationships to build out a robust, normalized database framework.
   
3. Data Transformation & Aggregation (ETL Layer):Developed custom SQLite script workflows to clean records and aggregate data fields into focused, performant dimension and fact summary tables.
   
4. Data Visualization & Dashboard Design: Connected the processed summary data directly into Power BI, engineering a cohesive dashboard interface utilizing deliberate color palettes and custom-designed layout wireframes to optimize user readability.












