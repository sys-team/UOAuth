create or replace function ea.confirm()
returns xml
begin

    declare @response xml;
    declare @code long varchar;
    declare @userId integer;
    
    set @code = isnull(http_variable('code'),'');
    
    set @userId = (select id
                     from dbo.udUser
                    where confirmationCode = @code
                      and confirmationTs >= dateadd(minute, -30, now())
                      and confirmed = 0);
    
    if @userId is null then
        set @response = xmlelement('error','Wrong confirmation code');
        return @response;
    end if;
    
    update dbo.udUser
       set confirmed = 1
     where id = @userId;
     
    set @response = xmlelement('code', ea.newAuthCode(@userId));

    return @response;

end
;