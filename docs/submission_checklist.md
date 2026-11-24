# Final Submission Checklist

## Before submission
- [ ] Replace all student/team/course/instructor/date placeholders in the report and slides.
- [ ] Read the report and confirm that it matches the instructor's exact rubric.
- [ ] Run `python -m pip install -r requirements.txt`.
- [ ] Run `python scripts/reset_database.py` only if you are comfortable resetting the local demo database.
- [ ] Run `python scripts/validate_database.py` and save the actual terminal output.
- [ ] Run `python -m pytest -q` and save the actual terminal output.
- [ ] Check the GitHub Actions workflow result for the latest commit.
- [ ] Open each page in the local app and capture genuine screenshots.
- [ ] Verify the screenshots do not expose private data or secrets.
- [ ] Review the SQL files and be ready to explain keys, constraints, normalization and triggers.
- [ ] Ensure the report and presentation use the same terminology and scope as the implementation.
- [ ] Submit the GitHub repository URL and any requested exported report/presentation files.

## Screenshot list
1. Dashboard at `/`
2. Student directory at `/students` (include a search example)
3. Course catalog at `/courses`
4. Section list at `/sections`
5. Enrollment page at `/enrollments`
6. Grade page at `/grades`

## Important
The local Flask application and the GitHub copy are separate. Changes committed to GitHub do not automatically modify files in an already-running local copy. Follow the instructor's required file format and naming convention.
