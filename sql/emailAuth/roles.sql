create or replace function ea.roles()
returns xml
begin
    declare @response xml;
    declare @code long varchar;
    declare @accountId integer;
    
    set @code = isnull(http_variable('code'),'');
    
    set @accountId = (select id
                        from dbo.udUser
                       where confirmed = 1
                         and authCode = @code);
    
    if @accountId is null then
        set @response = xmlelement('error','Not authorized');
        return @response;
    end if;
    
    set @response = xmlconcat(
        ea.accountRoles(@accountId),
        ea.accountData (@accountId)
    );
    
    return @response;
end
;