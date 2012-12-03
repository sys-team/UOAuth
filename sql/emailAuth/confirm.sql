create or replace function ea.confirm()
returns xml
begin

    declare @response xml;
    declare @code long varchar;
    declare @userId integer;
    declare @xid uniqueidentifier;
    
    set @code = isnull(http_variable('code'),'');
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'confirm' as service,
           http_body() as httpBody,
           @code as code;
    
    set @userId = (select id
                     from ea.account
                    where confirmationCode = @code
                      and confirmationTs >= dateadd(minute, -30, now())
                      and confirmed = 0);
    
    if @userId is null then
        set @response = xmlelement('error',xmlattributes('InvalidCode' as "code"), 'Wrong confirmation code');
    else

        update ea.account
           set confirmed = 1
         where id = @userId;
         
        set @response = xmlelement('access_token', ea.newAuthCode(@userId));
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;

    return @response;
end
;