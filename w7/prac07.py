#!/usr/bin/env python3

# average ratings

import sys
import psycopg2

# taster: shows the average they give for beers
# beer: shows the average rating for that beer
# brewer: shows avg rating for beers made by that brewer

if len(sys.argv) != 3:
    print("Usage: ./avgrat taster|beer|brewer Name", file=sys.stderr)
    exit(0)

arg = sys.argv[1]

if arg != 'taster' and arg != 'beer' and arg != 'brewer':
    print("Usage: ./avgrat taster|beer|brewer Name", file=sys.stderr)
    exit(0)    
    
name = sys.argv[2]

try:
    conn = psycopg2.connect("dbname=beers")
except Exception:
    print("Error connecting to db: beers")
    exit(0)
    
cur = conn.cursor()

if arg == 'taster':
    cur.execute("""
                select round(avg(r.score)::numeric, 1) as score
                from ratings r 
                join taster t on t.given = %s
                where r.taster = t.id
                """, (name,))
    score = cur.fetchone()[0]
    
    if score is None:
        print(f"No taster called '{name}'", file=sys.stderr)
        conn.close()
        exit(0)
    else:
        print(f"Average rating for taster {name} is {score}")
     
elif arg == 'beer':
    cur.execute("""
                select round(avg(r.score)::numeric, 1) as score
                from ratings r
                join beer b on b.name = %s
                where b.id = r.beer
                """, (name,))
    score = cur.fetchone()[0]
    
    if score is None:
        print(f"No ratings for {name}", file=sys.stderr)
        conn.close()
        exit(0)
    else:
        print(f"Average rating for beer {name} is {score}")
        
elif arg == 'brewer':
    cur.execute("""
                select round(avg(r.score)::numeric, 1) as score
                from ratings r
                join brewer br on br.name = %s
                join beer b on b.brewer = br.id
                where r.beer = b.id
                """, (name,))
    score = cur.fetchone()[0]
    if score is None:
        print(f"No ratings for {name}", file=sys.stderr)
        conn.close()
        exit(0)
    else:
        print(f"Average rating for {name} is {score}")
        
conn.close()

