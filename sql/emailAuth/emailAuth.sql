create or replace function ea.emailAuth(@url long varchar)
returns xml
begin

    declare @response xml;

    case @url
    
        when 'login' then
            set @response = ea."login"();
        when 'register' then
            set @response = ea.register();
        when 'confirm' then
            set @response = ea.confirm();
        
    end case;

    set @response = xmlelement('response', @response);

    return @response;

end
;