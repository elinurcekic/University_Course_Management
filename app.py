from pathlib import Path
import os
import sqlite3
from flask import Flask, flash, redirect, render_template, request, url_for

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "database" / "university.db"


def create_app(test_config=None):
    app = Flask(__name__)
    app.config.update(SECRET_KEY=os.environ.get("UCMS_SECRET_KEY", "local-development-key-change-before-deployment"))
    if test_config:
        app.config.update(test_config)

    def db():
        conn = sqlite3.connect(app.config.get("DATABASE", DB_PATH))
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA foreign_keys = ON")
        return conn

    @app.route("/")
    def index():
        with db() as conn:
            stats = {
                "students": conn.execute("SELECT COUNT(*) FROM student WHERE status='ACTIVE'").fetchone()[0],
                "courses": conn.execute("SELECT COUNT(*) FROM course WHERE is_active=1").fetchone()[0],
                "sections": conn.execute("SELECT COUNT(*) FROM section").fetchone()[0],
                "enrollments": conn.execute("SELECT COUNT(*) FROM enrollment WHERE status='ENROLLED'").fetchone()[0],
            }
            recent = conn.execute("""
                SELECT e.enrollment_id, p.first_name || ' ' || p.last_name AS student_name,
                       c.course_code, c.title, s.section_number, e.enrollment_date
                FROM enrollment e
                JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                ORDER BY e.enrollment_id DESC LIMIT 8
            """).fetchall()
        return render_template("index.html", stats=stats, recent=recent)

    @app.route("/students")
    def students():
        q = request.args.get("q", "").strip()
        with db() as conn:
            rows = conn.execute("""
                SELECT st.student_id, st.student_number, st.program, st.level, st.status,
                       p.first_name, p.last_name, p.email, d.department_name
                FROM student st JOIN person p ON p.person_id=st.person_id
                JOIN department d ON d.department_id=st.department_id
                WHERE (?='' OR st.student_number LIKE ? OR p.first_name LIKE ?
                       OR p.last_name LIKE ? OR p.email LIKE ?)
                ORDER BY p.last_name, p.first_name
            """, (q, f"%{q}%", f"%{q}%", f"%{q}%", f"%{q}%")).fetchall()
        return render_template("students.html", students=rows, q=q)

    @app.route("/courses")
    def courses():
        with db() as conn:
            rows = conn.execute("""
                SELECT c.course_id, c.course_code, c.title, c.credits, d.department_name
                FROM course c JOIN department d ON d.department_id=c.department_id
                WHERE c.is_active=1 ORDER BY c.course_code
            """).fetchall()
        return render_template("courses.html", courses=rows)

    @app.route("/sections")
    def sections():
        with db() as conn:
            rows = conn.execute("""
                SELECT s.section_id, c.course_code, c.title, s.section_number,
                       t.term_name, s.capacity, s.status,
                       p.first_name || ' ' || p.last_name AS instructor_name,
                       (SELECT COUNT(*) FROM enrollment e
                        WHERE e.section_id=s.section_id AND e.status='ENROLLED') AS enrolled
                FROM section s JOIN course c ON c.course_id=s.course_id
                JOIN academic_term t ON t.term_id=s.term_id
                LEFT JOIN instructor i ON i.instructor_id=s.instructor_id
                LEFT JOIN person p ON p.person_id=i.person_id
                ORDER BY t.start_date DESC, c.course_code, s.section_number
            """).fetchall()
        return render_template("sections.html", sections=rows)

    @app.route("/enrollments", methods=["GET", "POST"])
    def enrollments():
        with db() as conn:
            if request.method == "POST":
                try:
                    conn.execute("""
                        INSERT INTO enrollment(student_id, section_id, enrollment_date, status)
                        VALUES (?, ?, date('now'), 'ENROLLED')
                    """, (request.form["student_id"], request.form["section_id"]))
                    conn.commit()
                    flash("Student enrolled successfully.", "success")
                except sqlite3.IntegrityError as exc:
                    conn.rollback()
                    flash(f"Enrollment could not be completed: {exc}", "error")
                return redirect(url_for("enrollments"))
            students = conn.execute("""
                SELECT st.student_id, st.student_number,
                       p.first_name || ' ' || p.last_name AS full_name
                FROM student st JOIN person p ON p.person_id=st.person_id
                WHERE st.status='ACTIVE' ORDER BY st.student_number
            """).fetchall()
            sections = conn.execute("""
                SELECT s.section_id, c.course_code || ' - ' || c.title ||
                       ' / ' || s.section_number || ' (' || t.term_name || ')' AS label
                FROM section s JOIN course c ON c.course_id=s.course_id
                JOIN academic_term t ON t.term_id=s.term_id
                WHERE s.status='OPEN' ORDER BY c.course_code
            """).fetchall()
            rows = conn.execute("""
                SELECT e.enrollment_id, st.student_number,
                       p.first_name || ' ' || p.last_name AS student_name,
                       c.course_code, c.title, s.section_number, e.status, e.enrollment_date
                FROM enrollment e JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                ORDER BY e.enrollment_id DESC
            """).fetchall()
        return render_template("enrollments.html", students=students, sections=sections, enrollments=rows)

    @app.route("/grades", methods=["GET", "POST"])
    def grades():
        with db() as conn:
            if request.method == "POST":
                try:
                    conn.execute("""
                        INSERT INTO grade(enrollment_id, assessment_name, score, max_score, recorded_at)
                        VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP)
                        ON CONFLICT(enrollment_id, assessment_name)
                        DO UPDATE SET score=excluded.score, max_score=excluded.max_score,
                                      recorded_at=CURRENT_TIMESTAMP
                    """, (request.form["enrollment_id"], request.form["assessment_name"],
                          request.form["score"], request.form["max_score"]))
                    conn.commit()
                    flash("Grade saved.", "success")
                except (sqlite3.IntegrityError, ValueError) as exc:
                    conn.rollback()
                    flash(f"Grade could not be saved: {exc}", "error")
                return redirect(url_for("grades"))
            eligible = conn.execute("""
                SELECT e.enrollment_id, st.student_number,
                       p.first_name || ' ' || p.last_name AS student_name,
                       c.course_code, s.section_number
                FROM enrollment e JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                WHERE e.status='ENROLLED' ORDER BY e.enrollment_id
            """).fetchall()
            rows = conn.execute("""
                SELECT g.grade_id, g.assessment_name, g.score, g.max_score,
                       e.enrollment_id, st.student_number,
                       p.first_name || ' ' || p.last_name AS student_name, c.course_code
                FROM grade g JOIN enrollment e ON e.enrollment_id=g.enrollment_id
                JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                ORDER BY g.grade_id DESC
            """).fetchall()
        return render_template("grades.html", eligible=eligible, grades=rows)

    @app.errorhandler(404)
    def not_found(_error):
        return render_template("404.html"), 404

    return app


app = create_app()

if __name__ == "__main__":
    DB_PATH.parent.mkdir(exist_ok=True)
    if not DB_PATH.exists():
        with sqlite3.connect(DB_PATH) as conn:
            conn.execute("PRAGMA foreign_keys=ON")
            conn.executescript((BASE_DIR / "database" / "schema.sql").read_text())
            conn.executescript((BASE_DIR / "database" / "sample_data.sql").read_text())
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "5000")), debug=False)
