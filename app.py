from pathlib import Path
import os
import sqlite3
from flask import Flask, flash, redirect, render_template, request, url_for

BASE_DIR = Path(__file__).resolve().parent
DB_PATH = BASE_DIR / "database" / "university.db"


def create_app(test_config=None):
    app = Flask(__name__)
    app.config.update(
        SECRET_KEY=os.environ.get("UCMS_SECRET_KEY", "local-development-key-change-before-deployment"),
        MIDTERM_WEIGHT=40,
        FINAL_WEIGHT=60,
    )
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
                FROM enrollment e JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                ORDER BY e.enrollment_id DESC LIMIT 8
            """).fetchall()
        return render_template("index.html", stats=stats, recent=recent)

    @app.route("/students", methods=["GET", "POST"])
    def students():
        q = request.args.get("q", "").strip()
        with db() as conn:
            if request.method == "POST":
                try:
                    first_name = request.form.get("first_name", "").strip()
                    last_name = request.form.get("last_name", "").strip()
                    email = request.form.get("email", "").strip()
                    student_number = request.form.get("student_number", "").strip()
                    program = request.form.get("program", "").strip()
                    department_id = int(request.form.get("department_id", ""))
                    level = int(request.form.get("level", ""))
                    admission_date = request.form.get("admission_date", "").strip()
                    if not all([first_name, last_name, email, student_number, program, admission_date]):
                        raise ValueError("Please complete all required student fields.")
                    if not 1 <= level <= 8:
                        raise ValueError("Level must be between 1 and 8.")
                    cur = conn.execute(
                        "INSERT INTO person(first_name,last_name,email) VALUES (?,?,?)",
                        (first_name, last_name, email),
                    )
                    conn.execute("""
                        INSERT INTO student(person_id,student_number,department_id,program,level,admission_date)
                        VALUES (?,?,?,?,?,?)
                    """, (cur.lastrowid, student_number, department_id, program, level, admission_date))
                    conn.commit()
                    flash(f"Student {student_number} was added successfully.", "success")
                except (sqlite3.IntegrityError, ValueError) as exc:
                    conn.rollback()
                    flash(f"Student could not be added: {exc}", "error")
                return redirect(url_for("students"))
            rows = conn.execute("""
                SELECT st.student_id, st.student_number, st.program, st.level, st.status,
                       p.first_name, p.last_name, p.email, d.department_name
                FROM student st JOIN person p ON p.person_id=st.person_id
                JOIN department d ON d.department_id=st.department_id
                WHERE (?='' OR st.student_number LIKE ? OR p.first_name LIKE ?
                       OR p.last_name LIKE ? OR p.email LIKE ?)
                ORDER BY p.last_name, p.first_name
            """, (q, f"%{q}%", f"%{q}%", f"%{q}%", f"%{q}%")).fetchall()
            departments = conn.execute(
                "SELECT department_id, department_name FROM department ORDER BY department_name"
            ).fetchall()
        return render_template("students.html", students=rows, q=q, departments=departments)

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
                enrollment_id = request.form.get("enrollment_id", "").strip()
                try:
                    if not enrollment_id:
                        raise ValueError("Choose a student enrollment.")
                    saved = []
                    for assessment in ("Midterm", "Final"):
                        raw_score = request.form.get(assessment.lower(), "").strip()
                        if raw_score == "":
                            continue
                        score = float(raw_score)
                        if not 0 <= score <= 100:
                            raise ValueError(f"{assessment} score must be between 0 and 100.")
                        conn.execute("""
                            INSERT INTO grade(enrollment_id,assessment_name,score,max_score,recorded_at)
                            VALUES (?,?,?,100,CURRENT_TIMESTAMP)
                            ON CONFLICT(enrollment_id,assessment_name)
                            DO UPDATE SET score=excluded.score,max_score=100,recorded_at=CURRENT_TIMESTAMP
                        """, (enrollment_id, assessment, score))
                        saved.append(assessment)
                    if not saved:
                        raise ValueError("Enter at least one of the Midterm or Final scores.")
                    conn.commit()
                    flash("Saved: " + " and ".join(saved) + ".", "success")
                except (sqlite3.IntegrityError, ValueError) as exc:
                    conn.rollback()
                    flash(f"Grades could not be saved: {exc}", "error")
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
                SELECT e.enrollment_id, st.student_number,
                       p.first_name || ' ' || p.last_name AS student_name,
                       c.course_code, s.section_number,
                       MAX(CASE WHEN g.assessment_name='Midterm' THEN g.score END) AS midterm,
                       MAX(CASE WHEN g.assessment_name='Final' THEN g.score END) AS final
                FROM enrollment e JOIN student st ON st.student_id=e.student_id
                JOIN person p ON p.person_id=st.person_id
                JOIN section s ON s.section_id=e.section_id
                JOIN course c ON c.course_id=s.course_id
                LEFT JOIN grade g ON g.enrollment_id=e.enrollment_id
                GROUP BY e.enrollment_id
                ORDER BY st.student_number,c.course_code
            """).fetchall()
        return render_template(
            "grades.html", eligible=eligible, grades=rows,
            midterm_weight=app.config["MIDTERM_WEIGHT"], final_weight=app.config["FINAL_WEIGHT"]
        )

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
            conn.executescript((BASE_DIR / "database" / "expanded_sample_data.sql").read_text())
    app.run(host="127.0.0.1", port=int(os.environ.get("PORT", "5000")), debug=False)
