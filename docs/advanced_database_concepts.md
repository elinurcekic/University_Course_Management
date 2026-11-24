# Advanced Database Topics: Current Coverage

| Topic | Current project status |
|---|---|
| ER/EER modeling | Documented |
| Relational mapping and keys | Implemented/documented |
| SQL and database programming | Implemented |
| Normalization | Documented |
| Indexing | Implemented |
| Query processing | SQL examples included; inspect with EXPLAIN QUERY PLAN |
| Transactions | Basic SQLite transaction handling |
| Distributed databases | Not implemented; future extension |
| NoSQL | Not implemented; future extension |
| Data warehousing / OLAP | Not implemented; future extension |
| Big Data processing | Not implemented; future extension |
| Data mining | Not implemented; future extension |
| Security | Parameterized SQL and database constraints; authentication/authorization absent |

## Suggested extensions
1. Migrate to PostgreSQL for concurrent multi-user deployment if needed.
2. Add authentication, role-based authorization, CSRF protection, audit events, backups and privacy controls.
3. Build a separate de-identified analytical warehouse and ETL process for OLAP reports.
4. Use NoSQL only for data that genuinely requires flexible document structure; preserve transactional enrollment and grade facts in the relational database.
5. Evaluate distributed processing only when workload and scale justify the complexity.

The current application is an educational prototype. Do not publish real student records or secrets.