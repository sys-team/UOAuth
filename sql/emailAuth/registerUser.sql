create or replace function ea.registerUser(
    @id integer,
    @login long varchar,
    @email long varchar,
    @password long varchar
)
returns integer
begin
    declare @result integer;
    
    insert into ea.account on existing update with auto name
    select @id as id,
           @login as username,
           hash(@password,'SHA256') as password,
           @email as email,
           newid() as confirmationCode,
           now() as confirmationTs;
           
    set @result = @@identity;
    
    return @result;
end
;