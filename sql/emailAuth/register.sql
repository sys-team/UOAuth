create or replace function ea.register(
    @login long varchar default isnull(http_variable('login'),''),
    @password long varchar default isnull(http_variable('password'),''),
    @email long varchar default isnull(http_variable('email'),''),
    @callback long varchar default http_variable('callback'),
    @smtpSender long varchar default http_variable('smtp-sender'),
    @smtpServer long varchar default http_variable('smtp-server'),
    @subject long varchar default http_variable('subject')
)
returns xml
begin
    declare @response xml;
    declare @userId integer;
    declare @xid GUID;
    declare @msg xml;
    declare @confirmationTs datetime;
    declare @code long varchar;
    
    set @xid = newid();
    
    insert into ea.log with auto name
    select @xid as xid,
           'register' as service,
           http_body() as httpBody,
           @login as "login",
           @password as password,
           @email as email;
           
    -- register or change request
    select id,
           confirmationTs
       into @userId, @confirmationTs
       from ea.account
      where (username = @login
         or email = @login)
        and @email = ''
        and confirmed = 1;
        
    -- register
    if @userId is null and @email <> '' then
           
        if @login not regexp '[[:alnum:].-_]{3,15}' then
            set @response = xmlelement('error', xmlattributes('InvalidLogin' as "code"),
                           'Login must be at least 3, maximum 15 character in length and contains only alphanumeric, underscore and dash characters');
            
            update ea.log
               set response = @response
             where xid = @xid;
            
            return @response;
        end if;
    
        if @email not regexp '.+@.+\..+' then
            set @response = xmlelement('error', xmlattributes('InvalidEmail' as "code"),
                                       'Invalid email address');
            
            update ea.log
               set response = @response
             where xid = @xid;
            
            return @response;
        end if;
            
        -- delete rotten login
        delete from ea.account
         where (username = @login
            or email = @email)
           and confirmed = 0
           and confirmationTs < dateadd(minute, -30, now());
           
    
        set @msg = (select xmlconcat(
                           if username = @login then xmlelement('error',xmlattributes('LoginInUse' as "code"), 'This name is already in use') else null endif,
                           if email = @email then xmlelement('error',xmlattributes('EmailInUse' as "code"),'This email is already in use') else null endif,
                           if confirmed = 1 and password <> hash(@password,'SHA256') then xmlelement('error',xmlattributes('PassMismatch' as "code"),'Password mismatch for confirmed user') else null endif)
                      from ea.account
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
    
        -- min 6 char length
        -- number or spechial char
        -- lowercase
        -- uppercase
        if ea.passwordCheck(@password) = 0 then
            set @response = xmlelement('error', xmlattributes('InvalidPass' as "code"),
                                      'Password must be at least 6 characters, including an uppercase letter and a special character or number');
            
            update ea.log
               set response = @response
             where xid = @xid;
             
            return @response;
        end if;
    
        set @userId = (select id
                         from ea.account
                        where username = @login
                           or email = @email);
                           
        
        set @userId = ea.registerUser(@userId, @login, @email, @password, @xid);
        
        call ea.sendConfirmation(@userId, @callback, @smtpSender, @smtpServer, @subject);
    
        set @response = xmlelement('registered');
    else
    
        if @userId is null then
            set @response = xmlelement('error', xmlattributes('InvalidLogin' as "code"),
                                       'Invalid login');
            
            update ea.log
               set response = @response
             where xid = @xid;
            
            return @response;
        else
            if datediff(mi, @confirmationTs, now()) > 5 then
            
                set @code = ea.newConfirmationCode(@userId, 5, @xid);
    
                call ea.sendConfirmation(@userId, @callback, @smtpSender, @smtpServer, @subject);
             end if;
             
             set @response = xmlelement('accepted');
        end if;
    end if;
    
    update ea.log
       set response = @response
     where xid = @xid;
    
    return @response;
end
;