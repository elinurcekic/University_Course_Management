# Test Results

## Database validation
Run:

```bash
python scripts/validate_database.py
```

The validator creates a temporary SQLite database and checks integrity_check, foreign_key_check, required relations/views/triggers, fictional sample data, duplicate registration rejection, grade range validation, orphan foreign-key rejection, capacity enforcement, timetable conflict enforcement, grade eligibility and execution of both SQL example files.

**Observed result in the prepared project package: all database validation checks passed.** This is database-level evidence, not evidence that the Flask web routes have passed.

## Flask route tests
The route test suite is tests/test_app.py. Run locally in an environment with dependencies installed:

```bash
python -m pip install -r requirements.txt
python -m pytest -q
```

The Flask route suite was not executed in the packaging environment because Flask was unavailable there. Record the actual local terminal output before submission.