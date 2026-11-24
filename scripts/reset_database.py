from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "database" / "university.db"


def main():
    if DB.exists():
        DB.unlink()
    with sqlite3.connect(DB) as conn:
        conn.execute("PRAGMA foreign_keys=ON")
        conn.executescript((ROOT / "database" / "schema.sql").read_text())
        conn.executescript((ROOT / "database" / "sample_data.sql").read_text())
    print(f"Initialized {DB}")


if __name__ == "__main__":
    main()
