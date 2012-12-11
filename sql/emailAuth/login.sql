create or replace function ea."login"(
    @login long varchar default http_variable('login'),
    @password long varchar default http_variable('password')
)
returns xml
begin
    declare @response xml;
    declare @userId integer;
    declare @xid uniqueidentifier;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'login' as service,
           http_body() as httpBody,
           @login as "login",
           @password as password;
    
    set @userId = (select id
                     from ea.account
                    where (username = @login
                       or email = @login)
                      and password = hash(@password,'SHA256')
                      and confirmed = 1);
                      
    if @userId is null then
        set @response = xmlelement('error', xmlattributes('InvalidLogPass' as "code"), 'Wrong login or password');
    else
        set @response = xmlelement('access_token', ea.newAuthCode(@userId));
    end if;
    
    update ea.account
       set lastLogin = now()
      where id = @userId;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
    
end
;
