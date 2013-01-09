create or replace function ea.checkAccessToken(@code long varchar)
returns integer
begin
    declare @result integer;
    
    set @result = coalesce((select id
                              from ea.account
                             where confirmed = 1
                               and authCode = @code),
                           (select account
                              from ea.code
                             where code = @code
                               and now() between cts and ets));
                               
    return @result;
end
;