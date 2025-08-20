-- takes eventId
--- gives list of quitters

create or replace function getFinalCheckpoint(_eventId integer) returns integer
as $$
declare
    routeId integer;
    final_checkpoint integer;
begin

    select route_id into routeId
    from events 
    where id = _eventId;


    select cp.id into final_checkpoint
    from checkpoints cp
    join (
        select route_id, max(ordering) as max_ordering
        from checkpoints
        group by route_id
    ) t on cp.route_id = t.route_id and cp.ordering = t.max_ordering
    where cp.route_id = routeId
    ;

    return final_checkpoint;

end;
$$ language plpgsql
;

create or replace function ifPersonReachFinal(_eventId integer, _personId integer) returns boolean
as $$
declare
    par_id integer;
    final_checkpoint integer;
    result integer;
begin
    select id into par_id
    from participants 
    where person_id = _personId and event_id = _eventId;

    select getFinalCheckpoint(_eventId) into final_checkpoint;

    select count(*) into result
    from reaches
    where partic_id = par_id and chkpt_id = final_checkpoint;

    if result = 0 then
        return false;
    else 
        return true;
    end if;


end;
$$ language plpgsql
;


create or replace function personNotReachFinal(_eventId integer) returns setof integer
as $$
declare
    rec record;
begin
    for rec in
        select person_id, event_id from participants where event_id = _eventId
    loop
        if not ifPersonReachFinal(rec.event_id, rec.person_id) then
            return next rec.person_id;
        end if;
    end loop;
    return;
end;
$$ language plpgsql
;

create or replace function personGaveUpAt(_personId integer, _eventId integer) returns text
as $$
declare
    par_id integer;
    final_checkpoint_id integer;
    final_location text;
begin
    select id into par_id
    from participants 
    where person_id = _personId and event_id = _eventId;


    select r.chkpt_id into final_checkpoint_id
    from reaches r
    join (
        select partic_id, max(at_time) as final
        from reaches
        group by partic_id
    ) t on t.partic_id = r.partic_id and t.final = r.at_time
    where r.partic_id = par_id;


    select location into final_location
    from checkpoints
    where id = final_checkpoint_id;

    return final_location;
end;
$$ language plpgsql
;

 

create or replace function q3(_eventId integer) returns setof text
as $$
declare
    isEventExist integer;
    numPersonNotReachFinal integer;
    rec record;
    gaveUpAt text;
    _name text;
begin
    select count(*) into isEventExist
    from events e
    where e.id = _eventId;

    if isEventExist = 0 then
        return query values ('No such event');
    end if;

    select count(*) from personNotReachFinal(_eventId) into numPersonNotReachFinal;

    if numPersonNotReachFinal = 0 then
        return query values ('Nobody gave up');
    end if;

    for rec in
        select * from personNotReachFinal(_eventId)
    loop
        select personGaveUpAt(rec.personNotReachFinal, _eventId) into gaveUpAt;
        select name from people where id = rec.personNotReachFinal into _name;
        return next _name||' gave up at ' || gaveUpAt;
    end loop;
    return;

end;
$$ language plpgsql
;