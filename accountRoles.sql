create or replace function ua.accountRoles(@accountId integer)
returns xml
begin
    declare @result xml;
    
    set @result = (select xmlelement('roles', xmlconcat(xmlagg(xmlelement('role',r.code)),xmlelement('role','authenticated')))
                    from ua.accountRole ar join ua.role r on ar.role = r.id
                   where ar.account = @accountId);
 
    return @result;

end
;