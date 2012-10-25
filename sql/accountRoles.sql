create or replace function ua.accountRoles(@accountId integer)
returns xml
begin
    declare @result xml;
    
    set @result =( select
            xmlelement( 'roles'
                ,xmlagg(xmlelement('role',xmlforest(r.code,ar.data)))
                ,xmlelement('role',xmlelement('code','authenticated'))
            )
        from ua.accountRole ar join ua.role r on ar.role = r.id
        where ar.account = @accountId)
    ;
 
    return @result;

end;