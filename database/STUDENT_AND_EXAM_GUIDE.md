# Student registration and exam-grade update

## Student registration
Open **Students** in the Flask application. Use the **Add a new student** form to save a student. The form creates the related `person` row and `student` row in one database transaction. Email and student number uniqueness are enforced by the database.

## Midterm and Final grades
Open **Grades**. Select an enrolled student/course and enter Midterm, Final, or both. Scores are 0–100 and each exam is saved as its own row in `grade` with assessment names `Midterm` and `Final`. Saving an existing assessment updates it instead of creating a duplicate.

The report shows both columns and a weighted total when both scores exist. The demonstration weighting is **40% Midterm + 60% Final**, configured in `app.py` as `MIDTERM_WEIGHT` and `FINAL_WEIGHT`.

## Expanded sample results
The expanded seed now contains separate Midterm and Final rows for its 90 expanded enrollments. To rebuild the local demo database:

```bash
python scripts/reset_database.py
python app.py
```

The reset deletes and recreates `database/university.db`; back up any local data first.
