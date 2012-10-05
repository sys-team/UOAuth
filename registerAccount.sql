create or replace function ua.registerAccount(
    @authProviderCode long varchar,
    @clientCode long varchar,
    @refreshToken long varchar,
    @providerData xml
)
returns integer
begin
    declare @accountId integer;
    declare @clientId integer;
    declare @authProviderId integer;
    declare @accountProviderDataId integer;
    declare @accountClientDataId integer;
    declare @email varchar(1024);
    
    case @authProviderCode
        when 'google' then
            set @email = (select email
                            from openxml(@providerData ,'/*:response')
                                 with(email varchar(1024) '*:email'));
        
    end case;
    
    set @accountId = (select id
                        from ua.account
                       where email = @email);
                    
    insert into ua.account on existing update with auto name
    select @accountId as id,
           @email as name,
           @email as email;
           
    set @accountId = (select id
                        from ua.account
                       where email = @email);
                       
    set @authProviderId = (select id
                             from ua.authProvider
                            where code = @authProviderCode);
                       
    set @accountProviderDataId = (select id
                                    from ua.accountProviderData
                                   where account = @accountId
                                     and authProvider = @authProviderId);
                                     
    insert into ua.accountProviderData on existing update with auto name
    select @accountProviderDataId as id,
           @accountId as account,
           @authProviderId as authProvider,
           @providerData as providerData,
           @refreshToken as providerRefreshToken;
           
    set @accountProviderDataId = (select id
                                    from ua.accountProviderData
                                   where account = @accountId
                                     and authProvider = @authProviderId);
    
    set @clientId = (select id
                       from ua.client
                      where code = @clientCode);
                                   
    insert into ua.accountClientData  with auto name
    select @clientId as client,
           @accountId as account,
           null as authCode,
           null as refreshToken,
           null as accessToken;
           
    set @accountClientDataId = @@identity;       

    return @accountClientDataId;

end
;