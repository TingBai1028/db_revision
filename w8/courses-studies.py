#!/usr/bin/env python3

import sys
import psycopg2

if len(sys.argv) < 3:
    print("Usage: course-roll subject term", file=sys.stderr)
    exit(0)
    
subject = sys.argv[1]
term = sys.argv[2]

print(f"{subject} {term}")

try:
    conn = psycopg2.connect("dbname=uni")
except Exception:
    print("Failed when connecting database: uni", file=sys.stderr)
    exit(0)

cur = conn.cursor()

cur.execute("""
            select p.id, p.family, p.given
            from people p
            join terms t on t.code = %s
            join subjects s on s.code = %s
            join courses c on c.subject = s.id and c.term = t.id
            join course_enrolments ce on ce.course = c.id
            where p.id = ce.student
            """, (term,subject,))

enrolments = cur.fetchall()

if not enrolments:
    conn.close()
    print("No students")
    exit()
    
for id, family, given in enrolments:
    print(f"{id} {family}, {given}")

conn.close()
