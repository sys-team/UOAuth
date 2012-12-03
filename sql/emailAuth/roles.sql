create or replace function ea.roles(
    @code long varchar default http_variable('access_token')
)
returns xml
begin
    declare @response xml;
    declare @accountId integer;
    declare @xid uniqueidentifier;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'roles' as service,
           http_body() as httpBody,
           @code as code;
    
    set @accountId = (select id
                        from ea.account
                       where confirmed = 1
                         and authCode = @code);
    
    if @accountId is null then
        set @response = xmlelement('error', xmlattributes('InvalidAccessToken' as "code"),'Not authorized');
    else
         set @response = xmlconcat(
            ea.accountRoles(@accountId),
            ea.accountData (@accountId)
        );
        
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;