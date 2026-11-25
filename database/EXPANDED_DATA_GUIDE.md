# Expanded UCMS dataset and query library

## Data included

The expanded seed file adds the following fictional demonstration records to the original seed data:

- 30 additional students (35 total)
- 18 additional courses (23 total)
- 6 additional instructors (8 total)
- 18 additional sections (23 total)
- 90 additional registrations (95 total)
- 90 additional assessment records (94 total)

All generated names and email addresses are fictional; the email domain is example.edu.

## Load the expanded database

From the project root run:

```bash
python scripts/reset_database.py
```

The reset script recreates the local database and loads, in order, the schema, original sample data and expanded sample data. **This deletes the existing local demo database**, so export any local changes you need before running it.

If you only want to add the expanded records to a database that already contains the original schema and sample data, run:

```bash
python -c "import sqlite3; c=sqlite3.connect('database/university.db'); c.execute('PRAGMA foreign_keys=ON'); c.executescript(open('database/expanded_sample_data.sql').read()); c.commit(); c.close()"
```

## Extended SQL queries

Open `database/query_examples_extra.sql`. It contains 25 examples: exact-course rosters, Mathematics department rosters, popular courses, student course loads, grade averages, instructor assignments, schedules, prerequisite maps, seat availability and department comparisons.

Example: change `MATH201` in query 1 to `CS202` or `BUS201` to inspect another course's enrolled students.
