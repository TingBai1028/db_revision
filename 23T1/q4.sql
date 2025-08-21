-- COMP3311 23T1 Final Exam
-- Q4: Check whether account balance is consistent with transactions

create or replace function q4(_acctID integer)
	returns text
as $$
declare
	_balance integer;
	transaction_type Transaction_type;
	_amount integer;
	rec record;
	_calculatedBalance integer := 0;
begin
	perform * from accounts where id = _acctID;
	if not found then
		return 'No such account';
	end if;

	-- find balance
	select balance into _balance 
	from accounts 
	where id = _acctID;

	
	-- as a source account
	for rec in
		select ttype, amount
		from transactions 
		where source = _acctID
	loop
		if rec.ttype = 'withdrawal' or rec.ttype = 'transfer' then
			-- minus
			_calculatedBalance := _calculatedBalance - rec.amount;
		else 
			-- plus
			_calculatedBalance := _calculatedBalance + rec.amount;
		end if;
	end loop;

	-- as a dest account
	for rec in
		select ttype, amount
		from transactions 
		where dest = _acctID
	loop
		if rec.ttype = 'withdrawal' or rec.ttype = 'transfer' then
			-- plus
			_calculatedBalance := _calculatedBalance - rec.amount;
		else 
			-- minous
			_calculatedBalance := _calculatedBalance + rec.amount;
		end if;
	end loop;


	if _balance = _calculatedBalance then 
		return 'ok';
	else 
		return 'Mismatch: calculated balance ' || _calculatedBalance::text || ', stored balance ' || _balance::text;
	end if;

end;
$$ language plpgsql;
