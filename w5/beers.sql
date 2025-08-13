-- COMP3311 09s1 Prac Exercise
-- Written by: YOUR NAME (April 2009)


-- AllRatings view 

-- taster | beer | brewer | rating

-- rating: r.taster, r.beer, rating
-- taster id = r.taster --> given name
-- beer id = r.beer --> name, b.brewer
-- brewer id = b.brewer --> name

create or replace view AllRatings(taster,beer,brewer,rating)
as
select t.given, b.name, br.name, r.score
from ratings r 
join taster t on t.id = r.taster 
join beer b on b.id = r.beer
join brewer br on br.id = b.brewer
order by t.given;


-- John's favourite beer

create or replace view JohnsFavouriteBeer(brewer,beer)
as
select ar.beer as beer, ar.brewer as brewer
from AllRatings ar 
where ar.taster = 'John' and ar.rating = (
    select max(rating) from AllRatings where ar.taster = 'John'
)
;


-- X's favourite beer

create type BeerInfo as (brewer text, beer text);

create or replace function FavouriteBeer(taster text) returns setof BeerInfo
as $$
select ar.brewer, ar.beer
from AllRatings ar
where ar.taster = $1 and ar.rating = (
    select max(rating) from AllRatings ar where ar.taster = $1
)
$$ language sql
;


-- Beer style

create or replace function BeerStyle(brewer text, beer text) returns text
as $$
select bs.name as BeerStyle
from BeerStyle bs 
join beer b on b.name = $2
join brewer br on br.name = $1
where b.brewer = br.id and b.style = br.id
$$ language sql
;

create or replace function BeerStyle1(brewer text, beer text) returns text
as $$
declare
    result text;
begin
	select bs.name into result
    from BeerStyle bs 
    join beer b on b.name = $2
    join brewer br on br.name = $1
    where b.brewer = br.id and b.style = br.id;
    return result;
end;
$$ language plpgsql
;


-- Taster address

-- using case 
-- create or replace function TasterAddress(taster text) returns text
-- as $$
-- 	select 
--         case when loc.state is not null then loc.state||', '||loc.country
--         else loc.country
--         end
-- 	from   Taster t, Location loc
-- 	where  t.given = $1 and t.livesIn = loc.id
-- $$ language sql
-- ;

-- using coalesce
-- create or replace function TasterAddress(taster text) returns text
-- as $$
-- 	select 
--         coalesce(loc.state||', ', '')||loc.country
-- 	from   Taster t, Location loc
-- 	where  t.given = $1 and t.livesIn = loc.id
-- $$ language sql
-- ;

create or replace function TasterAddress(taster text) returns text
as $$
declare
    result text;
begin
	select coalesce(loc.state||', ', '')||loc.country into result
    from taster t, Location loc
    where t.given = $1 and t.livesIn = loc.id;
    return result;
end;
$$ language plpgsql
;


-- BeerSummary function

create or replace function BeerDetail(beerName text)
returns table (
    beer varchar(50),
    taster varchar(30), 
    rating int
)
as $$

begin
    return query
    select ar.beer, ar.taster, ar.rating
    from AllRatings ar 
    where ar.beer = $1;
end;
$$ language plpgsql;

create or replace function BeerDetailPrint(beername text) returns text
as $$
declare
    beerName text;
    rating float;
    tasters text;
    result text;
begin 
    beerName := $1;
    select round(avg(bd.rating)::numeric, 1), string_agg(bd.taster, ', ' order by bd.taster)
    into rating, tasters
    from BeerDetail($1) bd;

    result := e'\n'||'Beer: '||beerName||e'\n'||'Rating: '||coalesce(rating, 0)||e'\n'||'Tasters: '||coalesce(tasters, '');
    return result;
end;
$$ language plpgsql;

create or replace function BeerSummary() returns text
as $$
declare
    result text := '';
    beerName record;
begin
    for beerName in 
        select name from beer
    loop
        result := result || BeerDetailPrint(beerName.name) || e'\n';
    end loop;
    return result;
end;
$$ language plpgsql;



-- Concat aggregate

-- stype
create type concatType as ( str text );

-- sfunc
create or replace function concatString (s concatType, str text) returns concatType
as $$
begin
    if str is not null then
        if s.str is null then
            s.str := str;
        else 
            s.str := s.str || ',' || str;
        end if;
    end if;
    return s;
end;
$$ language plpgsql;

create aggregate concat (text)
(
	stype     = concatType,
	initcond  = '("")',
	sfunc     = concatString
);


-- BeerSummary view

create or replace view BeerSummary(beer,rating,tasters)
as
select ar.beer as beer, round(avg(ar.rating)::numeric, 1) as rating, concat(ar.taster) as tasters
from AllRatings ar
group by ar.beer
;


-- -- TastersByCountry view

-- create or replace view TastersByCountry(country,tasters)
-- as
-- 	... replace by SQL your query using concat() and Taster ...
-- ;
