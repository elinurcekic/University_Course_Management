# Test Results and Execution Record

## Automated verification

**PASS — GitHub Actions run #13 completed successfully** for the latest `main` commit reviewed in this submission-preparation pass.

- Workflow: UCMS tests
- Run: https://github.com/elinurcekic/University_Course_Management/actions/runs/45463692601
- Dependency installation: successful
- `python scripts/validate_database.py`: successful
- `python -m pytest -q`: successful

The workflow job and each of the above steps reported a successful conclusion. This is automated CI evidence for the repository commit that triggered run #13.

## Test coverage in the repository
- SQLite integrity and foreign-key checks
- Sample data and roster view
- Duplicate registration rejection
- Invalid grade range rejection
- HTTP 200 checks for dashboard and management pages
- Duplicate enrollment feedback
- Grade creation and display

The test plan is in `docs/test_plan.md`. Capacity and schedule-conflict triggers are implemented in the schema; dedicated automated cases for those trigger paths are not included in the current smoke validator and should not be claimed as separately tested.

## Evidence
Keep the GitHub Actions run URL above as evidence. If the instructor requires local terminal screenshots, run the same commands in the local project environment and capture the genuine output. The CI result does not verify screenshots or the state of a separate local project folder.
