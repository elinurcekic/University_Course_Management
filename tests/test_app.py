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
        "enrollment_id": "1", "final": "88"
    }, follow_redirects=True)
    assert response.status_code == 200
    assert b"Final" in response.data
    with sqlite3.connect(db) as conn:
        assert conn.execute(
            "SELECT score FROM grade WHERE enrollment_id=1 AND assessment_name='Final'"
        ).fetchone()[0] == 88


def test_student_can_be_added(tmp_path):
    db = tmp_path / "test.db"
    make_database(db)
    app = create_app({"TESTING": True, "DATABASE": str(db), "SECRET_KEY": "test"})
    client = app.test_client()
    response = client.post("/students", data={
        "first_name": "Test", "last_name": "Student", "email": "new.student@example.edu",
        "student_number": "TEST2026", "department_id": "1",
        "program": "BSc Computer Science", "level": "1", "admission_date": "2026-09-01"
    }, follow_redirects=True)
    assert response.status_code == 200
    assert b"TEST2026" in response.data
    with sqlite3.connect(db) as conn:
        assert conn.execute(
            "SELECT COUNT(*) FROM student WHERE student_number='TEST2026'"
        ).fetchone()[0] == 1


def test_midterm_and_final_are_separate_and_weighted(tmp_path):
    db = tmp_path / "test.db"
    make_database(db)
    app = create_app({"TESTING": True, "DATABASE": str(db), "SECRET_KEY": "test"})
    client = app.test_client()
    response = client.post("/grades", data={
        "enrollment_id": "1", "midterm": "70", "final": "90"
    }, follow_redirects=True)
    assert response.status_code == 200
    with sqlite3.connect(db) as conn:
        records = conn.execute(
            "SELECT assessment_name, score FROM grade WHERE enrollment_id=1 AND assessment_name IN ('Midterm','Final') ORDER BY assessment_name"
        ).fetchall()
    assert records == [("Final", 90.0), ("Midterm", 70.0)]
    assert b"82.00" in response.data
