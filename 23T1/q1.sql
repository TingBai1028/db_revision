-- COMP3311 23T1 Final Exam
-- Q1: suburbs with the most customers

create or replace view suburbCount(suburb, count)
as 
select c.lives_in as suburb, count(*)
from customers c 
group by c.lives_in;


create or replace view q1(suburb,ncust)
as
select suburb, count as ncust 
from suburbCount sc
where sc.count = (
    select max(count) from suburbCount
)
;
