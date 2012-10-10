create or replace function ua.registerAccount(
    @authProviderCode long varchar,
    @clientCode long varchar,
    @refreshToken long varchar,
    @providerData xml,
    @providerUid long varchar default null
)
returns integer
begin
    declare @accountId integer;
    declare @clientId integer;
    declare @authProviderId integer;
    declare @accountProviderDataId integer;
    declare @accountClientDataId integer;
    declare @email long varchar;
    declare @name long varchar;
    declare @code long varchar;
    
    case 
        when @authProviderCode in ('google','googlei') then
            select email,
                   name
              into @email, @name
              from openxml(@providerData ,'/*:response')
                  with(email long varchar '*:email', name long varchar '*:name');
                                 
        when @authProviderCode = 'facebook' then
        
            select top 1
                   name,
                   isnull(email, username + '@facebook.com')
              into @name, @email
              from openxml(@providerData ,'/*:response')
                    with(name long varchar '*:name', email long varchar '*:email', username long varchar '*:username');
                    
        when @authProviderCode = 'vk' then
        
            select first_name +' '+ last_name,
                   uid+'@vk.com'
              into @name, @email
              from openxml(@providerData, '/*:response/*:user')
                   with(first_name long varchar '*:first_name', last_name long varchar '*:last_name', uid long varchar '*:uid')
                          
        
    end case;
    
    set @accountId = (select id
                        from ua.account
                       where email = @email);
    
    if @accountId is null then
    
        set @code = @email;
    
        insert into ua.account on existing update with auto name
        select @accountId as id,
               isnull(@name,@email) as name,
               @email as email,
               @code as code;
               
        set @accountId = (select id
                            from ua.account
                           where email = @email);
    end if;
                       
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
           @refreshToken as providerRefreshToken,
           @providerUid as providerUid;
           
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