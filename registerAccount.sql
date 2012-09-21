create or replace function ua.registerAccount(@authProviderCode varchar(64), @refreshToken varchar(1024), @providerData xml)
returns integer
begin
    declare @result integer;
    declare @email varchar(1024);
    
    case @authProviderCode
        when 'google' then
            set @email = (select email
                            from openxml(@providerData ,'/*:response')
                                 with(email varchar(1024) '*:email'));
        
    end case;
    
    set @result = (select id
                     from ua.account
                    where email = @email);
                    
    insert into ua.account on existing update with auto name
    select @result as id,
           @email as name,
           @email as email,
           (select id from ua.authProvider where code = @authProviderCode) as authProvider,
           @refreshToken as providerRefreshToken,
           @providerData as providerData;
    
    set @result = (select id
                     from ua.account
                    where email = @email);    

    return @result;

end
;