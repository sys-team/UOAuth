create or replace function ua.accountData (
    @accountId integer
) returns xml begin

    declare @result xml;
    
    set @result = ( select
            xmlelement('account', xmlforest(
                    name, email, id, code
                )
            )
        from ua.account
        where account.id = @accountId);
 
    return @result;

end;