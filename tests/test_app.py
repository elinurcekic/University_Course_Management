import sqlite3
from pathlib import Path
from app import create_app

BASE = Path(__file__).resolve().parents[1]


def make_database(path):
    with sqlite3.connect(path) as conn:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.executescript((BASE / "database/schema.sql").read_text())
        conn.executescript((BASE / "database/sample_data.sql").read_text())


def test_dashboard_and_pages(tmp_path):
    db = tmp_path / "test.db"
    make_database(db)
    app = create_app({"TESTING": True, "DATABASE": str(db), "SECRET_KEY": "test"})
    client = app.test_client()
    for url in ["/", "/students", "/courses", "/sections", "/enrollments", "/grades"]:
        response = client.get(url)
        assert response.status_code == 200


def test_duplicate_enrollment_rejected(tmp_path):
    db = tmp_path / "test.db"
    make_database(db)
    app = create_app({"TESTING": True, "DATABASE": str(db), "SECRET_KEY": "test"})
    client = app.test_client()
    response = client.post("/enrollments", data={"student_id": "1", "section_id": "1"}, follow_redirects=True)
    assert b"Enrollment could not be completed" in response.data


def test_grade_insert(tmp_path):
    db = tmp_path / "test.db"
    make_database(db)
    app = create_app({"TESTING": True, "DATABASE": str(db), "SECRET_KEY": "test"})
    client = app.test_client()
    response = client.post("/grades", data={
        "enrollment_id": "1", "assessment_name": "Final", "score": "88", "max_score": "100"
    }, follow_redirects=True)
    assert response.status_code == 200
    assert b"Final" in response.data
