create or replace function ea.accountData (@accountId integer)
returns xml
begin
    declare @result xml;
    
    set @result = ( select xmlelement('account', xmlforest( username, email, id))
                      from dbo.udUser
                     where id = @accountId);
 
    return @result;
end;