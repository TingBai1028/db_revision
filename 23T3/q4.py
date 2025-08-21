#!/usr/bin/env python3

import sys
import psycopg2

if len(sys.argv) != 2:
    print("Wrong usage", file=sys.stderr)
    exit(0)
    

person = sys.argv[1]

try:
    conn = psycopg2.connect("dbname=funrun")
except Exception:
    print("Error connecting", file=sys.stderr)
    exit(0)
    
cur = conn.cursor()

# find person with name
cur.execute("""
            select id from people where name = %s
            """, (person,))
personId = cur.fetchone()

if personId is None:
    print("No such person", file=sys.stderr)
    conn.close()
    exit(0)

personId = personId[0]

# if found, look at the participation in events where they finished
# in chronological order 

# first print times for all events then trend message

cur.execute("""
            select id, event_id as eventId
            from participants
            where person_id = %s
            """, (personId,))

events = cur.fetchall()
count = 0
timesStr = None
times = []

for id, eventId in events:
    count += 1
    cur.execute("""
                select ifPersonReachFinal(%s, %s)
                """, (eventId, personId,))
    ifPersonReachFinal = cur.fetchone()[0]
    
    if ifPersonReachFinal:
        cur.execute("""
                    select r.at_time as time
                    from reaches r
                    join (
                        select partic_id, max(at_time) as final_time
                        from reaches
                        group by partic_id
                    ) t on t.partic_id = r.partic_id
                        and t.final_time = r.at_time
                    where r.partic_id = %s
                    """, (id,))
        time = cur.fetchone()[0]
        times.append(time)
        if timesStr is None:
            timesStr = f"t{count}={time}"
        else:
            timesStr = f"{timesStr}, t{count}={time}"

print(timesStr)

if count == 1:
    print("Cannot determine a strend")
elif count == 2:
    if times[0] > times[1]:
        print("Improving")
    else:
        print("Not improving")
elif count == 3:
    if times[0] > times[1] and times[1] > times[2]:
        print("Improving")
    else:
        print("Not improving")
        
    

conn.close()