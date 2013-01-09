create or replace function ea.token(
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
           'token' as service,
           http_body() as httpBody;

    set @accountId = ea.checkAccessToken(@code);
    
    if @accountId is null then
        set @response = xmlelement('error', xmlattributes('InvalidAccessToken' as "code"),'Not authorized');
    else
        set @response = xmlelement('access_token', ea.newCode(@accountId, @xid));
    end if;
           
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;