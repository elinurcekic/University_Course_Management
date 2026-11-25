# Expanded UCMS dataset and query library

## Dataset size after loading both seed files

The original seed file is retained. The optional expanded seed file adds:
- 30 fictional students (35 total including the original five)
- 18 additional courses (23 total)
- 6 additional instructors (8 total)
- 18 additional sections (23 total)
- 90 additional registrations (95 total)
- 90 additional grade records (94 total)

All added records use fictional names and example.edu email addresses.

## Load order

From the project root, initialize the schema and original seed data first, then run:

```bash
python -c "import sqlite3; c=sqlite3.connect('database/university.db'); c.execute('PRAGMA foreign_keys=ON'); c.executescript(open('database/expanded_sample_data.sql').read()); c.commit(); c.close()"
```

Or execute the script in SQLite after the original schema and sample data have been loaded. The file uses INSERT OR IGNORE so it can be safely re-run against the same database.

## Query examples

Open `database/query_examples_extra.sql`. It contains 25 additional queries, including exact-course rosters, Mathematics department rosters, popularity rankings, student course loads, grade averages, instructor assignments, schedule reports, prerequisites and seat availability.

Example: change `MATH201` in query 1 to `CS202`, `BUS201` or another course code to see its enrolled students.
