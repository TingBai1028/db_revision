-- shows people who finshed events in the fastest time
-- sorted first by date then by name of person

-- 

-- event id, event name, participant id, participant name
create or replace view events_and_participants(par_id, event_id, date, event_name, person_id, person_name)
as
select pa.id as par_id, e.id as event_id, e.held_on as date, e.name as event_name, p.id as person_id, p.name as person_name
from participants pa 
join events e on pa.event_id = e.id
join people p on pa.person_id = p.id;


-- time person reach checkpoint in each event
create or replace view time_person_reach_checkpoint
as
select ep.event_id, ep.person_name, cp.location as checkpoint, r.at_time as time_taken
from events_and_participants ep
join events e on e.id = ep.event_id
join checkpoints cp on cp.route_id = e.route_id
join reaches r on r.chkpt_id = cp.id and r.partic_id = ep.par_id;

-- final checkpoint for each event
create or replace view event_route_final_checkpoint
as
select e.id as event_id, e.name as event_name, cp.location as final_checkpoint
from events e 
join checkpoints cp on cp.route_id = e.route_id
where cp.ordering = (
    select max(cp.ordering) from checkpoints cp
    where cp.route_id = e.route_id
);

create or replace view person_reach_final
as

select ep.event_id as event_id, ep.event_name as event, ep.date as date, tprc.person_name as person, tprc.time_taken as time, tprc.checkpoint
from events_and_participants ep
join event_route_final_checkpoint erfc on erfc.event_id = ep.event_id
join time_person_reach_checkpoint tprc on tprc.checkpoint = erfc.final_checkpoint and tprc.event_id = erfc.event_id

;

create or replace view q2(event, date, person, time) as
select distinct prf.event, prf.date, prf.person, prf.time
from person_reach_final prf
join (
    select event_id, min(time) as time
    from person_reach_final
    group by event_id
) t on prf.event_id = t.event_id and prf.time = t.time
order by prf.date, prf.person
;
