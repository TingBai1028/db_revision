#! /usr/bin/env python3

# COMP3311 23T1 Final Exam
# Q5: Print details of accounts at a named branch

import sys
import psycopg2

### Constants
USAGE = f"Usage: {sys.argv[0]} <branch name>"

### Globals
db = None

### Queries

### replace this line with any query templates ###

### Command-line args
if len(sys.argv) != 2:
    print(USAGE, file=sys.stderr)
    sys.exit(1)
suburb = sys.argv[1]


try:
    db = psycopg2.connect("dbname=bank")
    
    cur = db.cursor()
    
    cur.execute("""
                select id from branches where location = %s
                """,(suburb,))
    
    branchId = cur.fetchone()
    if branchId is None:
        print(f"No such branch {suburb}", file=sys.stderr)
        db.close()
        sys.exit(1)
        
    branchId = branchId[0]
    print(f"{suburb} branch ({branchId}) holds")
    
    cur.execute("""
                select c.given || ' ' || c.family as name, c.lives_in as location, a.id as acc_id, a.balance as balance
                from held_by hb
                join accounts a on a.id = hb.account
                join customers c on c.id = hb.customer
                join branches b on b.id = a.held_at and b.id = %s
                order by a.id
                """, (branchId,))
    
    accountsInfo = cur.fetchall()
    
    summ = 0
    for name, location, accId, balance in accountsInfo:
        print(f"- account {accId} owned by {name} from {location} with ${balance}")
        summ = summ + int(balance)
        
    print(f"Assets: ${str(summ)}")
    
    cur.execute("""
                select assets
                from branches
                where id = %s
                """, (branchId,))
    assets = cur.fetchone()[0]
    assets = int(assets)
    if summ != assets:
        print("Discrepancy between assets and sum of account balances")
    

except psycopg2.Error as err:
    print("DB error: ", err)
except Exception as err:
    print("Internal Error: ", err)
    raise err
finally:
    if db is not None:
        db.close()
        

sys.exit(0)

### replace this line by any helper functions ###
