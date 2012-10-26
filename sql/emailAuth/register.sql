create or replace function ea.register()
returns xml
begin
    declare @result xml;
    
    declare @login long varchar;
    declare @password long varchar;
    declare @email long varchar;
    declare @userId integer;

    set @login = isnull(http_variable('login'),'');
    set @password = isnull(http_variable('password'),'');
    set @email = isnull(http_variable('email'),'');
    
    -- min 6 char length
    -- number or spechial char
    -- lowercase
    -- uppercase
    if @password not regexp '(?=^.{6,}$)((?=.*\d)|(?=.*\W))(?=.*[a-z])(?=.*[A-Z]).*$' then
        set @result = xmlelement('error','Wrong password');
        return @result;
    end if;
    
    if @email not regexp '.+@.+\..+' then
        set @result = xmlelement('error','Wrong email address');
        return @result;
    end if;
    
    if length(@login) = 0 then
        set @result = xmlelement('error','Wrong login');
        return @result;
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
        set @result = xmlelement('error','Login already in use');
        return @result;
    end if;
    
    set @userId = (select id
                     from dbo.udUser
                    where username = @login
                       or email = @email);
    
    set @userId = ea.registerUser(@userId, @login, @email, @password);
    
    call ea.sendConfirmation(@userId);
    
    set @result = xmlelement('registered');
    
    return @result;
end
;