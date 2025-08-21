-- COMP3311 23T1 Final Exam
-- Q2: ids of people with same name

create or replace view customerName(id, name)
as 
select c.id as id, c.given || ' ' || c.family as name
from customers c 
order by c.id asc
;

create or replace view q2(name,ids)
as
select cn.name, string_agg(cn.id::text, ',') as ids
from customerName cn 
where exists (
    select * from customerName
    where name = cn.name and id != cn.id
)
group by cn.name
order by cn.name asc
;

-- ;

