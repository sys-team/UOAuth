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
        when 'roles' then
            set @response = ea.roles();
        when 'check' then
            set @response = ea."check"();
        when 'token'then
            set @response = ea.token();
    end case;
        
    set @response = xmlelement('response', xmlattributes('https://github.com/sys-team/UOAuth' as "xmlns"), @response);
        
    return @response;  
end
;