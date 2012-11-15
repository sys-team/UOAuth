create or replace function ea.accountRoles(@accountId integer)
returns xml
begin
    declare @result xml;
    
    set @result = (select xmlelement( 'roles', xmlelement('role',xmlelement('code','authenticated')))
                     from dbo.udUser
                    where id = @accountId);
 
    return @result;
end;