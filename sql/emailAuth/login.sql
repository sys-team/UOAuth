create or replace function ea."login"()
returns xml
begin
    declare @response xml;
    declare @login long varchar;
    declare @password long varchar;
    declare @userId integer;
    declare @xid uniqueidentifier;
    
    set @login = http_variable('login');
    set @password = http_variable('password');
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'login' as service,
           http_body() as httpBody,
           @login as "login",
           @password as password;
    
    set @userId = (select id
                     from dbo.udUser
                    where (username = @login
                       or email = @login)
                      and password = hash(@password,'SHA256')
                      and confirmed = 1);
                      
    if @userId is null then
        set @response = xmlelement('error', 'Not authorized');
    else
        set @response = xmlelement('code', ea.newAuthCode(@userId));
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
    
end
;
