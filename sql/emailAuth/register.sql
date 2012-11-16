create or replace function ea.register()
returns xml
begin
    declare @response xml;
    
    declare @login long varchar;
    declare @password long varchar;
    declare @email long varchar;
    declare @userId integer;
    declare @xid uniqueidentifier;

    set @login = isnull(http_variable('login'),'');
    set @password = isnull(http_variable('password'),'');
    set @email = isnull(http_variable('email'),'');
    
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
        set @response = xmlelement('error','Wrong password');
        
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
    
    if exists(select *
                from dbo.udUser
               where (username = @login
                  or email = @email)
                 and (confirmed = 1
                  or password <> hash(@password,'SHA256'))) then
        set @response = xmlelement('error','Login already in use');
        
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
    
    call ea.sendConfirmation(@userId);
    
    set @response = xmlelement('registered');
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;