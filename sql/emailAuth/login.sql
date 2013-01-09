create or replace function ea."login"(
    @login long varchar default http_variable('login'),
    @password long varchar default http_variable('password')
)
returns xml
begin
    declare @response xml;
    declare @userId integer;
    declare @xid uniqueidentifier;
    declare @isAccessToken integer;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'login' as service,
           http_body() as httpBody,
           @login as "login",
           @password as password;
           
    set @userId = ea.checkAccessToken(@password);
    
    if @userId is not null then
        set @isAccessToken = 1;
    else
        select id
          into @userId
          from ea.account
         where (username = @login
            or email = @login)
           and password = hash(@password,'SHA256')
           and confirmed = 1;
           
        set @isAccessToken = 0;
    end if;    
                      
    if @userId is null then
        set @response = xmlelement('error', xmlattributes('InvalidLogPass' as "code"), 'Wrong login or password');
    else
        if @isAccessToken = 0 then
            set @response = xmlelement('access_token', ea.newAuthCode(@userId));
        else
            set @response = xmlelement('access_token', @password);
        end if;
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
