# ER/EER Model

```mermaid
erDiagram
  DEPARTMENT ||--o{ STUDENT : has
  DEPARTMENT ||--o{ INSTRUCTOR : employs
  DEPARTMENT ||--o{ COURSE : owns
  PERSON ||--o| STUDENT : subtype
  PERSON ||--o| INSTRUCTOR : subtype
  COURSE ||--o{ SECTION : offered_as
  ACADEMIC_TERM ||--o{ SECTION : contains
  INSTRUCTOR o|--o{ SECTION : teaches
  CLASSROOM o|--o{ SECTION : hosts
  SECTION ||--o{ COURSE_SCHEDULE : scheduled_at
  STUDENT ||--o{ ENROLLMENT : registers
  SECTION ||--o{ ENROLLMENT : receives
  ENROLLMENT ||--o{ GRADE : assessed_by
  COURSE ||--o{ COURSE_PREREQUISITE : prerequisite_relationship
```

## EER specialization
PERSON is the supertype. STUDENT and INSTRUCTOR are partial, potentially overlapping subtypes. A person may have neither subtype row or both. Each subtype has a unique person_id foreign key to PERSON. The database does not enforce total specialization or disjointness.

Rendered diagram sources should be kept in docs/diagrams/ in the full project package.