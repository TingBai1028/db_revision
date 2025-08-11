-- COMP3311 Prac Exercise
--
-- Written by: YOU


-- Q1: how many page accesses on March 2


create or replace view Q1(nacc) as
select count(*)
from accesses a
where a.accTime between '2005-03-02 00:00:00' and '2005-03-03 00:00:00'
;


-- Q2: how many times was the MessageBoard search facility used?


create or replace view Q2(nsearches) as
select count(*)
from accesses a 
where a.page like '%webcms/messageboard%' and a.params like '%state=search%'
;


-- Q3: on which Tuba lab machines were there incomplete sessions?

-- tuba lab
-- webcms sessions 
-- uncomplete --> session.complete = false
-- we want host name --> hosts.hostname

create or replace view Q3(hostname) as
select distinct h.hostname as hostname
from hosts h 
join sessions s on s.complete is FALSE
where s.host = h.id and h.hostname like '%tuba%'
;


-- Q4: min,avg,max bytes transferred in page accesses

create or replace view Q4(min,avg,max) as
select min(nbytes), round(avg(nbytes)), max(nbytes)
from accesses
;


-- Q5: number of sessions from CSE hosts

create or replace view Q5(nhosts) as
select count(*)
from sessions s 
join hosts h on h.hostname like '%cse.unsw.edu.au'
where s.host = h.id 
;


-- Q6: number of sessions from non-CSE hosts


create or replace view Q6(nhosts) as
select count(*)
from sessions s 
join hosts h on h.hostname not like '%cse.unsw.edu.au'
where s.host = h.id 
;


-- Q7: session id and number of accesses for the longest session?

create or replace view sessionLen as 
select session, count(*) as len 
from accesses
group by session;

create or replace view Q7(session,length) as 
select session, len as length
from sessionLen
where len = (select max(len) from sessionLen)
;


-- Q8: frequency of page accesses


create or replace view Q8(page,freq) as
select page, count(*) as frequency
from accesses
group by page
;


-- Q9: frequency of module accesses


create or replace view Q9(module,freq) as
select substring(page from '^[^/]+') as module, count(*) as freq
from accesses
group by module
;


-- Q10: "sessions" which have no page accesses

create or replace view Q10(session) as
select id 
from sessions
where id not in(
    select distinct session
    from accesses
)
;


-- Q11: hosts which are not the source of any sessions

create or replace view Q11 as
select h.hostname as unused
from hosts h 
left outer join Sessions s on s.host = h.id 
group by h.hostname
having count(s.id) = 0
;
