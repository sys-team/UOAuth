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
        set @response = ua.auth();
    elseif @url = 'token' then
        set @response = ua.token();
    elseif @url = 'roles' then
        set @response = ua.roles();
    end if;
    
    set @response = '<?xml version="1.0" encoding="utf-8"?>'
                  + xmlelement('response', xmlattributes('http://unact.net/xml/oauth' as "xmlns"), @response);
           
    update ua.log
       set response = @response
     where xid = @xid;
    
    call sa_set_http_header ( 'Content-Type', 'text/xml; charset=utf-8' );
    call sa_set_http_option ( 'CharsetConversion', 'off');
    
    return @response;
    
    -- Пока во всех случаях 404 вернём
    exception  
        when others then 
            call op.errorHandler('ua.UOAuth',SQLSTATE,errormsg()); 
            commit;

            call dbo.sa_set_http_header('@HttpStatus', '404');

            return '';
            
    
end
;