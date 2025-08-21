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