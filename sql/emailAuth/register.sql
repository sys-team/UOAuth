create or replace function ea.register()
returns xml
begin
    declare @response xml;
    
    declare @login long varchar;
    declare @password long varchar;
    declare @email long varchar;
    declare @userId integer;
    declare @xid uniqueidentifier;
    declare @callback long varchar;
    declare @msg xml;

    set @login = isnull(http_variable('login'),'');
    set @password = isnull(http_variable('password'),'');
    set @email = isnull(http_variable('email'),'');
    set @callback = isnull(http_variable('callback'),'');
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'register' as service,
           http_body() as httpBody,
           @login as "login",
           @password as password,
           @email as email;
    
    -- min 6 char length
    -- number or spechial char
    -- lowercase
    -- uppercase
    if @password not regexp '(?=^.{6,}$)((?=.*\d)|(?=.*\W))(?=.*[a-z])(?=.*[A-Z]).*$' then
        set @response = xmlelement('error','Password must be at least 6 characters, including a uppercase letter and a special character or number');
        
        update ea.log
           set response = @response
         where xid = @xid;
         
        return @response;
    end if;
    
    if @email not regexp '.+@.+\..+' then
        set @response = xmlelement('error','Wrong email address');
        
        update ea.log
           set response = @response
         where xid = @xid;
        
        return @response;
    end if;
    
    if length(@login) = 0 then
        set @response = xmlelement('error','Wrong login');
        
        update ea.log
           set response = @response
         where xid = @xid;
        
        return @response;
    end if;
    
    -- delete rotten login
    delete from dbo.udUser
     where (username = @login
        or email = @email)
       and confirmed = 0
       and confirmationTs < dateadd(minute, -30, now());
       
    set @msg = (select xmlconcat(
                       if username = @login then xmlelement('error','Login already in use') else null endif,
                       if email = @email then xmlelement('error','Email allready in use') else null endif,
                       if confirmed = 1 and password <> hash(@password,'SHA256') then xmlelement('error','Password mismatch for confirmed user') else null endif)
                  from dbo.udUser
                 where (username = @login
                    or email = @email)
                   and (confirmed = 1
                    or password <> hash(@password,'SHA256')));
    
    if @msg is not null then
                         
        set @response =  @msg;
        
        update ea.log
           set response = @response
         where xid = @xid; 
        
        return @response;
    end if;
    
    set @userId = (select id
                     from dbo.udUser
                    where username = @login
                       or email = @email);
    
    set @userId = ea.registerUser(@userId, @login, @email, @password);
    
    call ea.sendConfirmation(@userId, @callback);
    
    set @response = xmlelement('registered');
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;