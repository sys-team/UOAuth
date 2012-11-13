create or replace function upa.UPushAuth(@url long varchar)
returns xml
begin

    declare @response xml;

    case @url
    
        when 'register' then
            set @response = upa.register();
        when 'activate' then
            set @response = upa.activate();
        when 'auth' then
            set @response = upa.auth();
        when 'check-credentials' then
            set @response = upa.checkCredentials();
        
    end case;

    set @response = xmlelement('response', @response);

    return @response;

    -- Пока во всех случаях 404 вернём
    exception  
        when others then 
            call op.errorHandler('upa.UPushAuth',SQLSTATE,errormsg()); 
            commit;

            call dbo.sa_set_http_header('@HttpStatus', '404');

            return '';

end
;