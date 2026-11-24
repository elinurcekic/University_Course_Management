"""Small standard-library database smoke validator for the GitHub checkout."""
from pathlib import Path
import sqlite3
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    with tempfile.TemporaryDirectory() as temp:
        db = Path(temp) / "ucms.db"
        with sqlite3.connect(db) as conn:
            conn.execute("PRAGMA foreign_keys=ON")
            conn.executescript((ROOT / "database/schema.sql").read_text())
            conn.executescript((ROOT / "database/sample_data.sql").read_text())
            assert conn.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
            assert not conn.execute("PRAGMA foreign_key_check").fetchall()
            assert conn.execute("SELECT COUNT(*) FROM student").fetchone()[0] >= 5
            assert conn.execute("SELECT COUNT(*) FROM v_section_roster").fetchone()[0] >= 1
            try:
                conn.execute("INSERT INTO enrollment(student_id,section_id) VALUES(1,1)")
            except sqlite3.IntegrityError:
                pass
            else:
                raise AssertionError("duplicate enrollment was not rejected")
            try:
                conn.execute("INSERT INTO grade(enrollment_id,assessment_name,score,max_score) VALUES(1,'invalid',101,100)")
            except sqlite3.IntegrityError:
                pass
            else:
                raise AssertionError("invalid grade was not rejected")
    print("UCMS database smoke validation: PASS")


if __name__ == "__main__":
    main()
