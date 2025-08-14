#!/usr/bin/env python3

import sys
import psycopg2

pattern = sys.argv[1]

try:
    conn = psycopg2.connect("dbname=uni")
except Exception:
    print("Failed open databse: uni", file=sys.stderr)
    exit(0)
    
cur = conn.cursor()

cur.execute("""
            select o.name, count(*) as nsubjects
            from subjects s 
            join orgunits o on o.longname ILIKE %s
            where s.offeredby = o.id
            group by o.name
            """, (pattern,))

for name, nsubjects in cur.fetchall():
    print(name, nsubjects)

conn.close()

