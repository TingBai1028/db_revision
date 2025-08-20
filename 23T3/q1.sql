-- oldest participants
create or replace view events_participants_info(person, age, event, year)
as 
select p.name as person, ((e.held_on - p.d_o_b) / 365) as age, e.name as event, substr(e.held_on::text,1,4) as year
from participants pa 
join people p on pa.person_id = p.id
join events e on pa.event_id = e.id;



create or replace view q1(person, age, event)
as 
select ep.person, ep.age, ep.year::text||' '||ep.event
from events_participants_info ep
where ep.age = (
    select max(ep.age) from events_participants_info ep
)


