#!/usr/bin/env python3

import sys
import psycopg2

if len(sys.argv) != 3:
    print("wrong usage", file=sys.stderr)
    exit(0)
    
eventName = f"%{sys.argv[1]}%"
year = f"%{sys.argv[2]}%"

try:
    conn = psycopg2.connect("dbname=funrun")
except Exception:
    print("cannot connect", file=sys.stderr)
    exit(0)
    
cur = conn.cursor()

cur.execute("""
            select *
            from events
            where name ILIKE %s and held_on::text ilike %s
            """, (eventName, year,))

event = cur.fetchall()

if len(event) == 0:
    print("No matching event", file=sys.stderr)
    conn.close()
    exit(0)
elif len(event) > 1:
    print("Event/year is ambiguous", file=sys.stderr)
    conn.close()
    exit(0)


print(f"{event[0][1]}, {event[0][3]}")
eventId = event[0][0]

# participants finshed the race

# divides groups based on age
# < 20, 20-24, 25-29, 30-34, 35+
# name, age, finishing time
# order in name
# if no person in age group, print no par...
cur.execute("""
            select * 
            from participants
            where event_id = %s
            """,(eventId,))

participants = cur.fetchall()

group1 = []
group2 = []
group3 = []
group4 = []
group5 = []
for parId, personId, _ in participants:
    cur.execute("""
                select ifPersonReachFinal(%s, %s)
                """,(eventId,personId,))
    ifPersonReachFinal = cur.fetchone()[0]
    if ifPersonReachFinal:
        cur.execute("""
                    select name
                    from people
                    where id = %s
                    """,(personId,))
        personName = cur.fetchone()[0]
        
        cur.execute("""
                    select (e.held_on - p.d_o_b) / 365 as age
                    from participants pa
                    join people p on p.id = %s
                    join events e on e.id = %s
                    where pa.person_id = p.id and pa.event_id = e.id
                    """, (personId, eventId,))
        
        personAge = cur.fetchone()[0]
        
        cur.execute("""
                    select r.at_time as time
                    from reaches r
                    join (
                        select partic_id, max(at_time) as finish_time
                        from reaches
                        group by partic_id
                    ) t on t.partic_id = r.partic_id and t.finish_time = r.at_time
                    where r.partic_id = %s
                    """, (parId,))
        
        timeFinish = cur.fetchone()[0]
        
        person = [personName, personAge, timeFinish]
        
        if personAge < 20:
            group1.append(person)
        elif personAge >= 20 and personAge <= 24:
            group2.append(person)
        elif personAge >= 25 and personAge <= 29:
            group3.append(person)
        elif personAge >= 30 and personAge <= 34:
            group4.append(person)
        else:
            group5.append(person) 
    
print("under 20")
for person in group1:
    print(f"- {person[0]}, {person[1]}yo, {person[2]}mins")
if len(group1) == 0:
    print("- no participants in this age group")

print("20-24")
for person in group2:
    print(f"- {person[0]}, {person[1]}yo, {person[2]}mins")
if len(group2) == 0:
    print("- no participants in this age group")

print("25-29")
for person in group3:
    print(f"- {person[0]}, {person[1]}yo, {person[2]}mins")
if len(group3) == 0:
    print("- no participants in this age group")
print("30-34")
for person in group4:
    print(f"- {person[0]}, {person[1]}yo, {person[2]}mins")
if len(group4) == 0:
    print("- no participants in this age group")
print("35 and over")
for person in group5:
    print(f"- {person[0]}, {person[1]}yo, {person[2]}mins")
if len(group5) == 0:
    print("- no participants in this age group")    


conn.close()