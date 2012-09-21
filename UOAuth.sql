create or replace function ua.UOAuth(@url long varchar)
returns xml
begin
    declare @request long varchar;
    declare @response xml;
    declare @xid uniqueidentifier;
    
    set @request = http_body();
    set @xid = newid();
    
    insert into ua.log with auto name
    select @xid as xid,
           @url as url,
           @request as request;
    
    if @url = 'auth' then
        set @response = ua.auth(@request);
    elseif @url = 'access' then
        set @response = ua.access(@request);
    elseif @url = 'roles' then
        set @response = ua.roles();
    end if;
    
    set @response = '<?xml version="1.0" encoding="utf-8"?>'
                  + xmlelement('response', xmlattributes('http://unact.net/xml/oauth' as "xmlns"), @response);
           
    update ua.log
       set response = @response
     where xid = @xid;
    
    return @response;
    
end
;