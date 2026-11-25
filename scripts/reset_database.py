"""Reset the local demo database and load both original and expanded fictional data."""
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "database" / "university.db"


def main():
    # This is a destructive reset of the local demo database.
    if DB.exists():
        DB.unlink()
    with sqlite3.connect(DB) as conn:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.executescript((ROOT / "database" / "schema.sql").read_text(encoding="utf-8"))
        conn.executescript((ROOT / "database" / "sample_data.sql").read_text(encoding="utf-8"))
        conn.executescript((ROOT / "database" / "expanded_sample_data.sql").read_text(encoding="utf-8"))
        assert conn.execute("PRAGMA integrity_check").fetchone()[0] == "ok"
        assert not conn.execute("PRAGMA foreign_key_check").fetchall()
        print("Students:", conn.execute("SELECT COUNT(*) FROM student").fetchone()[0])
        print("Courses:", conn.execute("SELECT COUNT(*) FROM course").fetchone()[0])
        print("Enrollments:", conn.execute("SELECT COUNT(*) FROM enrollment").fetchone()[0])
    print(f"Initialized expanded UCMS demo database: {DB}")


if __name__ == "__main__":
    main()
