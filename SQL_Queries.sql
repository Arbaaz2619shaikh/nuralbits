-- 📊 1. Average Patients per Month, Week, and Year (by Hospital)
-- Calculates patient admission trends grouped by time

-- Monthly
SELECT hospital_id, 
       YEAR(admission_datetime) AS year, 
       MONTH(admission_datetime) AS month, 
       COUNT(*) AS patient_count
FROM patient
GROUP BY hospital_id, year, month;

-- Weekly
SELECT hospital_id, 
       YEAR(admission_datetime) AS year, 
       WEEK(admission_datetime) AS week, 
       COUNT(*) AS patient_count
FROM patient
GROUP BY hospital_id, year, week;

-- Yearly
SELECT hospital_id, 
       YEAR(admission_datetime) AS year, 
       COUNT(*) AS patient_count
FROM patient
GROUP BY hospital_id, year;

-- 📊 2. Hospital Occupancy (Daily, Weekly, Monthly, Yearly)

-- Daily Occupancy
SELECT DATE(admission_datetime) AS date, COUNT(*) AS admissions
FROM patient
GROUP BY DATE(admission_datetime);

-- Weekly
SELECT YEAR(admission_datetime) AS year, WEEK(admission_datetime) AS week, COUNT(*) AS admissions
FROM patient
GROUP BY year, week;

-- Monthly
SELECT YEAR(admission_datetime) AS year, MONTH(admission_datetime) AS month, COUNT(*) AS admissions
FROM patient
GROUP BY year, month;

-- Yearly
SELECT YEAR(admission_datetime) AS year, COUNT(*) AS admissions
FROM patient
GROUP BY year;

-- 📊 3. Age-wise Categorization of Patients

SELECT 
    CASE
        WHEN TIMESTAMPDIFF(YEAR, dob, CURDATE()) <= 12 THEN 'Child'
        WHEN TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN 13 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END AS age_group,
    COUNT(*) AS patient_count
FROM patient
GROUP BY age_group;

-- 📊 4. Most Consumed Medicine (Overall)

SELECT medicine_name, COUNT(*) AS times_used
FROM treatment
GROUP BY medicine_name
ORDER BY times_used DESC
LIMIT 1;

-- 📊 5. Most Consumed Medicine by Diagnosis

SELECT d.diagnosis_name, t.medicine_name, COUNT(*) AS usage_count
FROM diagnosis d
JOIN treatment t ON d.patient_id = t.patient_id
GROUP BY d.diagnosis_name, t.medicine_name
HAVING usage_count = (
    SELECT MAX(counted) FROM (
        SELECT d2.diagnosis_name AS diag, t2.medicine_name, COUNT(*) AS counted
        FROM diagnosis d2
        JOIN treatment t2 ON d2.patient_id = t2.patient_id
        GROUP BY diag, t2.medicine_name
    ) AS sub WHERE sub.diag = d.diagnosis_name
)
ORDER BY d.diagnosis_name;

-- 📊 6. Average Days of Hospitalization

SELECT 
    ROUND(AVG(DATEDIFF(discharge_datetime, admission_datetime)), 2) AS avg_days
FROM patient;

-- 📊 7. Monthly and Yearly Income with Cash/Credit Split

-- Monthly
SELECT 
    YEAR(p.admission_datetime) AS year,
    MONTH(p.admission_datetime) AS month,
    b.payment_mode,
    SUM(b.bill_amount) AS total_income
FROM billing b
JOIN patient p ON b.patient_id = p.patient_id
GROUP BY year, month, b.payment_mode
ORDER BY year, month;

-- Yearly
SELECT 
    YEAR(p.admission_datetime) AS year,
    b.payment_mode,
    SUM(b.bill_amount) AS total_income
FROM billing b
JOIN patient p ON b.patient_id = p.patient_id
GROUP BY year, b.payment_mode
ORDER BY year;
