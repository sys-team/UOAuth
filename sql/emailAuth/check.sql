create or replace function ea."check"(
    @login long varchar default http_variable('login')
)
returns xml
begin
    declare @result xml;
    
    if exists(select *
                from ea.account
               where (username = @login
                  or email = @login)
                 and confirmed = 1) then
        set @result = xmlelement('found');
    else
        set @result = xmlelement('not-found');
    end if;   
    
    return @result;
end
;