-- COMP3311 18s1 Prac 05 Exercises

-- Q1. What beers are made by Toohey's?

create or replace view Q1 as
select b.Name
from Beers b 
join brewers br on br.name = 'Toohey''s'
where b.brewer = br.id
;

-- Q2. Show beers with headings "Beer", "Brewer".

create or replace view Q2 as
select b.name as "Beer", br.name as "Brewer"
from Beers b, brewers br
where b.brewer = br.id
;

-- Q3. Find the brewers whose beers John likes.

-- drinkers: name = john --> drinkerId
-- likes: drinker = drinkerId --> likesBeer
-- beers: id = likesBeer --> brewer
-- brewers: id = brewer --> brewerName
create or replace view Q3 as
select br.name as brewer
from brewers br 
join drinkers d on d.name = 'John'
join likes l on l.drinker = d.id
join beers b on b.id = l.beer
where br.id = b.brewer
order by br.name
;

-- Q4. How many different beers are there?

create or replace view Q4 as
select count(*) as "#beers"
from beers
;

-- Q5. How many different brewers are there?

create or replace view Q5 as
select count(*) as "#brewers"
from brewers
;

-- Q6. Find pairs of beers by the same manufacturer
--     (but no pairs like (a,b) and (b,a), and no (a,a))

create or replace view Q6 as
select b1.name as beer1, b2.name as beer2
from beers b1, beers b2
where b1.brewer = b2.brewer and b1.id > b2.id
;

-- Q7. How many beers does each brewer make?

create or replace view Q7 as
select br.name as brewer, count(*) as nbeers
from brewers br, beers b
where b.brewer = br.id
group by br.name
;

-- Q8. Which brewer makes the most beers?

create or replace view Q8 as
select brewer 
from Q7
where nbeers = (select max(nbeers) from Q7)
;

-- Q9. Beers that are the only one by their brewer.

create or replace view onlyOneBeerBrewer as
select brewer
from Q7
where nbeers = 1
;

create or replace view Q9 as
select b.name as brewer
from beers b, onlyOneBeerBrewer obr
join brewers br on br.name = obr.brewer
where b.brewer = br.id;


-- Q10. Beers sold at bars where John drinks.

-- drinkers: name = John --> drinkers.id
-- frequents: drinker = drinkers.id --> freq.bar
-- sells: bar = freq.bar --> sells.beer
-- beers: id = sells.beer --> name (distinct)

create or replace view Q10 as
select distinct b.name as beer
from beers b
join drinkers d on d.name = 'John'
join frequents fr on fr.drinker = d.id
join sells s on s.bar = fr.bar
where b.id = s.beer
;

-- Q11. Bars where either Gernot or John drink.

-- create or replace view Q11 as
-- select distinct ba.name as bar
-- from bars ba 
-- join frequents fr on fr.bar = ba.id
-- where fr.drinker in(
--     select id from drinkers where name = 'Gernot' or name = 'John'
-- )
-- ;

create or replace view Q11 as
(
    select distinct ba.name as bar
    from bars ba
    join frequents fr on fr.bar = ba.id
    where fr.drinker = (select id from drinkers where name = 'John')
)
union
(
    select distinct ba.name as bar
    from bars ba
    join frequents fr on fr.bar = ba.id
    where fr.drinker = (select id from drinkers where name = 'Gernot')
)
;

-- Q12. Bars where both Gernot and John drink.

-- create or replace view Q12 as
-- select distinct ba.name as bar
-- from bars ba
-- join frequents fr1 on fr1.bar = ba.id
-- join frequents fr2 on fr2.bar = ba.id
-- where fr1.drinker = (select id from drinkers where name = 'Gernot')
--     and fr2.drinker = (select id from drinkers where name = 'John')
-- ;

create or replace view Q12 as
(
    select distinct ba.name as bar
    from bars ba
    join frequents fr on fr.bar = ba.id
    where fr.drinker = (select id from drinkers where name = 'John')
)
intersect
(
    select distinct ba.name as bar
    from bars ba
    join frequents fr on fr.bar = ba.id
    where fr.drinker = (select id from drinkers where name = 'Gernot')
)
;

-- Q13. Bars where John drinks but Gernot doesn't

create or replace view Q13 as
(
    select distinct ba.name as bar
    from bars ba
    join frequents fr1 on fr1.bar = ba.id
    where fr1.drinker = (select id from drinkers where name = 'John')
)
except
(
    select distinct ba.name as bar 
    from bars ba
    join frequents fr on fr.bar = ba.id
    where fr.drinker = (select id from drinkers where name = 'Gernot')
)

;

-- Q14. What is the most expensive beer?

create or replace view Q14 as
select b.name as beer
from beers b
join sells s on s.beer = b.id
where s.price = (select max(price) from sells)
;

-- Q15. Find bars that serve New at the same price
--      as the Coogee Bay Hotel charges for VB.

create or replace view Q15 as
select distinct ba.name as bar
from bars ba 
join sells s on s.bar = ba.id
where s.price = (
    select s.price
    from sells s
    join bars ba on ba.name = 'Coogee Bay Hotel'
    join beers b on b.name = 'Victoria Bitter'
    where s.bar = ba.id and s.beer = b.id
) and ba.name != 'Coogee Bay Hotel'
;

-- Q16. Find the average price of common beers
--      ("common" = served in more than two hotels).
create or replace view beers_and_bars as
select b.name as beer, ba.name as bar, s.price as price
from beers b, bars ba, sells s
where s.beer = b.id and s.bar = ba.id
order by b.name;


create or replace view Q16 as
select bb.beer as beer, ROUND(AVG(bb.price)::numeric,2) as "AvgPrice"
from beers_and_bars bb
group by bb.beer
having count(*) >= 2
;

-- Q17. Which bar sells 'New' cheapest?

create or replace view Q17 as
select bb.bar as bar
from beers_and_bars bb
where bb.beer = 'New'
    and bb.price = (
        select min(bb.price) from beers_and_bars bb
    )
;

-- Q18. Which bar is most popular? (Most drinkers)

create or replace view bars_and_drinkers as 
select b.name as bar, count(*)
from frequents fr 
join bars b on b.id = fr.bar
join drinkers d on d.id = fr.drinker
group by b.name;

create or replace view Q18 as
select bd.bar as bar
from bars_and_drinkers bd 
where bd.count = (
    select max(bd.count) from bars_and_drinkers bd
)
;

-- Q19. Which bar is least popular? (May have no drinkers)

create or replace view Q19 as
select bd.bar as bar
from bars_and_drinkers bd 
where bd.count = (
    select min(bd.count) from bars_and_drinkers bd
)
;

-- Q20. Which bar is most expensive? (Highest average price)

create or replace view bars_and_avgPrices as 
select bb.bar, ROUND(avg(bb.price)::numeric, 2) as avg
from beers_and_bars bb 
group by bb.bar;

create or replace view Q20 as
select ba.bar as bar
from bars_and_avgPrices ba 
where ba.avg = (
    select max(ba.avg) from bars_and_avgPrices ba 
)

;

-- Q21. Which beers are sold at all bars?

-- setA: all bars (id) from bars table
-- setB: sells -> one specific beer -> bars
-- if setA - setB = 0, then sold all bars

create or replace view Q21 as
select b.name as beer
from beers b 
join sells s on s.beer = b.id 
where not exists (
    (select id from bars)
    except
    (
        select s2.bar as id
        from sells s2 
        where s2.beer = s.beer
    )
)
;

-- Q22. Price of cheapest beer at each bar?

create or replace view Q22 as
select ba.bar as bar, min(ba.price) as min_price
from beers_and_bars ba 
group by ba.bar
;

-- Q23. Name of cheapest beer at each bar?

create or replace view Q23 as
select ba.bar as bar, ba.beer as beer
from beers_and_bars ba 
join q22 bar_min_price on ba.bar = bar_min_price.bar and ba.price = bar_min_price.min_price
;

-- Q24. How many drinkers are in each suburb?

create or replace view Q24 as
select d.addr, count(d.id)
from drinkers d 
group by d.addr
;

-- Q25. How many bars in suburbs where drinkers live?
--      (Must include suburbs with no bars)

-- left join: 
-- left table: drinkers, right table: bars
-- keep everything in drinkers even there is no match

-- right join:
-- keep everything in bars even there is no match (so 6 will appear)

create or replace view Q25 as
select d.addr, count(b.id) as "#bars"
from drinkers d 
left join bars b on b.addr = d.addr
group by d.addr
;
