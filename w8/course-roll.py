#!/usr/bin/env python3

import sys
import psycopg2

if len(sys.argv) < 3:
    print("Usage: id, term", file=sys.stderr)
    exit(0)

studentId = sys.argv[1]
term = sys.argv[2]
    
try:
    conn = psycopg2.connect("dbname=uni")
except Exception as e:
    print("Unable to connect to database uni")

cur = conn.cursor()

cur.execute("select * from students where id = %s", (studentId,))

if not cur.fetchall():
    print(f"Cannot find student with id {studentId}", file=sys.stderr)
    conn.close()
    exit(0)
    
cur.execute("""
            select s.code, s.name
            from subjects s
            join terms t on t.code = %s
            join course_enrolments ce on ce.student = %s 
            join courses c on c.id = ce.course and c.term = t.id
            where s.id = c.subject
            """, (term,studentId,))

for code, name in cur.fetchall():
    print(f"{code} {name}")
    
conn.close()

