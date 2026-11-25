"""Validate the expanded fictional dataset and execute the extended SQL query library."""
from pathlib import Path
import sqlite3
import tempfile
ROOT = Path(__file__).resolve().parents[1]

def main():
    with tempfile.TemporaryDirectory() as temp:
        with sqlite3.connect(Path(temp) / "ucms.db") as conn:
            conn.execute("PRAGMA foreign_keys=ON")
            for path in ("database/schema.sql","database/sample_data.sql","database/expanded_sample_data.sql"):
                try:
                    conn.executescript((ROOT / path).read_text(encoding="utf-8"))
                except sqlite3.Error as exc:
                    raise AssertionError(f"Failed while loading {path}: {exc}") from exc
            expected={"department":3,"person":43,"student":35,"instructor":8,"course":23,"classroom":9,"section":23,"enrollment":95,"grade":94}
            for table,count in expected.items():
                actual=conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
                assert actual==count, f"{table}: expected {count}, got {actual}"
            assert conn.execute("PRAGMA integrity_check").fetchone()[0]=="ok"
            assert not conn.execute("PRAGMA foreign_key_check").fetchall()
            roster=conn.execute("SELECT COUNT(*) FROM course c JOIN section s ON s.course_id=c.course_id JOIN enrollment e ON e.section_id=s.section_id AND e.status='ENROLLED' WHERE c.course_code='MATH201'").fetchone()[0]
            assert roster==5, f"MATH201 roster expected 5, got {roster}"
            raw=(ROOT/"database/query_examples_extra.sql").read_text(encoding="utf-8")
            statements=[]
            for part in raw.split(";"):
                stmt="\n".join(line for line in part.splitlines() if not line.strip().startswith("--")).strip()
                if stmt: statements.append(stmt)
            assert len(statements)==25, f"expected 25 queries, got {len(statements)}"
            for i,stmt in enumerate(statements,1):
                try: conn.execute(stmt).fetchall()
                except sqlite3.Error as exc: raise AssertionError(f"Extended query {i} failed: {exc}\n{stmt}") from exc
    print("Expanded dataset validation: PASS (35 students, 23 courses, 95 enrollments)")
    print("Extended query validation: PASS (25 queries executed)")
if __name__=="__main__": main()
