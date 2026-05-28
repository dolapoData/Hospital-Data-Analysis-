SELECT COUNT(*) as total_patients
FROM patients


SELECT gender, COUNT(*) AS total
FROM patients
group by gender; 


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



SELECT COUNT(*) AS total_encounters
FROM encounters;


SELECT
   strftime('%Y' , start) AS year,
   COUNT(*) AS total_encounters
 FROM encounters
 GROUP by year
 order by year;


SELECT reasondescriptio, COUNT(*) AS total
FROM encounters
WHERE reasondescriptio IS NOT NULL
GROUP BY reasondescriptio
ORDER BY total DESC
LIMIT 10;


SELECT organization, COUNT(*) AS total_encounters
FROM encounters
GROUP BY organization
ORDER BY total_encounters DESC
LIMIT 10;


SELECT encounterclass, COUNT(*) AS total
FROM encounters
GROUP BY encounterclass
ORDER BY total DESC;


SELECT description, COUNT(*) AS total
FROM procedures
GROUP BY description
ORDER BY total DESC
LIMIT 10;


SELECT AVG(base_cost) AS avg_treatment_cost
FROM procedures;


SELECT strftime('%Y', start) AS year,
       SUM(base_cost) AS total_cost
FROM procedures
GROUP BY year
ORDER BY year;


SELECT SUM(total_claim_cost) AS total_revenue
FROM encounters;                                       - Total_revenue 


SELECT strftime('%Y', start) AS year,
       SUM(total_claim_cost) AS total_revenue
FROM encounters
GROUP BY year
ORDER BY year;                                        - Total_revenue over time



SELECT payer, COUNT(*) AS total_encounters,
       SUM(total_claim_cost) AS total_revenue
FROM encounters
GROUP BY payer
ORDER BY total_revenue DESC;                           - Payment methods


SELECT patient, 
       SUM(total_claim_cost) AS total_spent
FROM encounters
GROUP BY patient
ORDER BY total_spent DESC
LIMIT 10;


SELECT e.patient,
       COUNT(e.id) AS total_visits,
       SUM(e.total_claim_cost) AS lifetime_value
FROM encounters e
GROUP BY e.patient
ORDER BY lifetime_value DESC
LIMIT 10;


SELECT e.patient,
       COUNT(e.id) AS total_visits,
       SUM(e.total_claim_cost) AS total_spent,
       ROUND(SUM(e.total_claim_cost) / COUNT(e.id), 2) AS avg_spent_per_visit
FROM encounters e
GROUP BY e.patient
ORDER BY total_visits DESC
LIMIT 10;                                                     - relationship between visit and spending





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



CREATE TABLE treatment_summary AS
SELECT 
  p.patient,
  p.encounter,
  p.description AS procedure_name,
  p.base_cost,
  p.reasondescriptio AS reason,
  strftime('%Y', p.start) AS year
FROM procedures p;



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




SELECT * FROM patient_summary;

SELECT * FROM organization_summary;

SELECT * FROM revenue_summary;

SELECT * FROM treatment_summary;

SELECT * FROM appointment_summary;

