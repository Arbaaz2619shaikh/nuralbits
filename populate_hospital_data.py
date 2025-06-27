import mysql.connector
from faker import Faker
from datetime import timedelta
import random

fake = Faker()
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="2619",
    database="project"
)
cursor = conn.cursor()

# Medicines & Diagnoses List
meds = ['Paracetamol', 'Ibuprofen', 'Amoxicillin', 'Cough Syrup', 'Vitamin C', 'Azithromycin']
diags = ['Fever', 'Cold', 'Flu', 'Infection', 'Allergy', 'Cough']

for pid in range(3, 100003):
    hid = random.randint(1, 5)
    name = fake.name()
    dob = fake.date_of_birth(minimum_age=1, maximum_age=80)
    admit = fake.date_time_between(start_date='-2y', end_date='-1d')
    discharge = admit + timedelta(days=random.randint(2, 8))
    cursor.execute("INSERT INTO patient (patient_id, hospital_id, patient_name, dob, admission_datetime, discharge_datetime) VALUES (%s,%s,%s,%s,%s,%s)",
                   (pid, hid, name, dob, admit, discharge))

    # Diagnoses (auto-increment id)
    for _ in range(2):
        diag = random.choice(diags)
        cursor.execute("INSERT INTO diagnosis (patient_id, diagnosis_name) VALUES (%s, %s)", (pid, diag))

    # Treatments (auto-increment id)
    for _ in range(5):
        med = random.choice(meds)
        time = f"{random.randint(7,21)}:00:00"
        dur = random.randint(3, 7)
        cursor.execute("INSERT INTO treatment (patient_id, medicine_name, dose_time, duration) VALUES (%s,%s,%s,%s)", (pid, med, time, dur))

    # Billing
    amt = random.randint(500, 5000)
    mode = random.choice(['cash', 'credit'])
    cursor.execute("INSERT INTO billing (patient_id, bill_amount, payment_mode) VALUES (%s,%s,%s)", (pid, amt, mode))

    if pid % 1000 == 0:
        conn.commit()
        print(f"{pid} records done...")

conn.commit()
cursor.close()
conn.close()
print("✅ 1 Lakh Records Inserted!")
