-- COMP3311 23T1 Final Exam
-- Q3: show branches where
-- *all* customers who hold accounts at that branch
-- live in the suburb where the branch is located

-- replace this line with any helper views --


-- where not exist a customer, helds on account in one branch
-- but lives in different location

create or replace view q3(branch)
as
select b.location as branch
from branches b 
where not exists (
    select 1
    from held_by hb 
    join customers c on c.id = hb.customer 
    join accounts a on a.id = hb.account and a.held_at = b.id
    where c.lives_in <> b.location
)

;
