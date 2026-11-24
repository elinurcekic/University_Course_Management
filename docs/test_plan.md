# UCMS Test Plan

## Test environment
- Python 3.12 (CI configuration)
- Flask and pytest from `requirements.txt`
- SQLite database created in a temporary directory for automated tests
- Fictional sample records only

## Test cases

| ID | Area | Test | Expected result | Evidence |
|---|---|---|---|---|
| TP-01 | Database | Create schema and load sample data | Tables and sample rows are created | `python scripts/validate_database.py` |
| TP-02 | Database | Run SQLite integrity check | Result is `ok` | Validator output |
| TP-03 | Database | Check foreign-key violations | No rows returned | Validator output |
| TP-04 | Enrollment | Register same student in same section twice | UNIQUE constraint rejects duplicate | Validator and route test |
| TP-05 | Grade | Save a score above its maximum | CHECK constraint rejects it | Validator |
| TP-06 | Web | Open dashboard and each management page | HTTP 200 | `tests/test_app.py` |
| TP-07 | Web | Submit duplicate enrollment | Error feedback is displayed | `tests/test_app.py` |
| TP-08 | Web | Add a grade for an enrolled student | Grade is saved and displayed | `tests/test_app.py` |
| TP-09 | Trigger | Enroll beyond section capacity | Trigger rejects operation | Extend validator when capacity fixture is prepared |
| TP-10 | Trigger | Enroll in overlapping schedule | Trigger rejects operation | Extend validator when schedule fixture is prepared |

## Execution commands

```bash
python -m pip install -r requirements.txt
python scripts/validate_database.py
python -m pytest -q
```

## Evidence policy
Record the actual command output and date after running tests. Do not mark a test as passed based only on the existence of a test script. Capture screenshots from the real running application; do not fabricate or edit screenshots to imply functionality that was not tested.
