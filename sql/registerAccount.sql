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
    declare @email long varchar;
    declare @name long varchar;
    declare @code long varchar;
    
    declare @providerUid long varchar;
    
    
    case 
        when @authProviderCode in ('google','googlei') then
            select email,
                   name,
                   uid
              into @email, @name, @providerUid
              from openxml(@providerData ,'/*:response')
                  with(email long varchar '*:email',
                       name long varchar '*:name',
                       uid long varchar '*:id');
                                 
        when @authProviderCode = 'facebook' then
        
            select top 1
                   name,
                   email,
                   uid
              into @name, @email, @providerUid
              from openxml(@providerData ,'/*:response')
                    with(name long varchar '*:name', 
                         email long varchar '*:email',
                         username long varchar '*:username',
                         uid long varchar '*:id');
                    
        when @authProviderCode = 'vk' then
        
            select first_name +' '+ last_name,
                   null,
                   uid 
              into @name, @email, @providerUid
              from openxml(@providerData, '/*:response/*:user')
                   with(first_name long varchar '*:first_name',
                        last_name long varchar '*:last_name',
                        uid long varchar '*:uid')
                   
        when @authProviderCode = 'mailru' then
        
            select fname+' '+lname as name,
                   email,
                   uid
              into @name, @email, @providerUid
              from openxml(@providerData, '/*:response_users_getInfo/*:user')
                   with(fname long varchar '*:first_name',
                        lname long varchar '*:last_name',
                        email long varchar '*:email',
                        uid long varchar '*:uid');
                        
        when @authProviderCode = 'odks' then
        
            select fname +' '+lname,
                   uid
              into @name, @providerUid
              from openxml(@providerData, '/*:user')
                   with(fname long varchar '*:first_name', lname long varchar '*:last_name',  uid long varchar '*:uid');

        when @authProviderCode = 'emailAuth' then
        
            select name,
                   email,
                   uid
              into @name, @email, @providerUid
              from openxml(@providerData , '/*:response')
                   with(name  long varchar 'login', email long varchar 'email', uid long varchar 'uid');
                   
        when @authProviderCode = 'UPushAuth' then
        
            select type + ' ' + xid,
                   xid
              into @name, @providerUid
              from openxml(@providerData,'/*:response/*:device')
                   with(type long varchar 'type', xid long varchar 'xid');

    end case;
    
    --message 'ua.registerAccount @providerData = ', @providerData; 
    --message 'ua.registerAccount @name = ',@name,' @email = ', @email, ' @providerUid = ', @providerUid;
    
    set @authProviderId = (select id
                             from ua.authProvider
                            where code = @authProviderCode);
                       
    
    set @accountId = isnull((select account
                               from ua.accountProviderData
                              where providerUid = @providerUid
                                and authProvider = @authProviderId),
                            (select id
                               from ua.account
                              where email = @email));
    
    if @accountId is null then
        
        set @code = isnull(@email, @providerUid+'@'+@authProviderCode);
        set @email = isnull(@email, @code);
    
        insert into ua.account on existing update with auto name
        select @accountId as id,
               isnull(@name,@email) as name,
               @email as email,
               @code as code;
               
        set @accountId = (select id
                            from ua.account
                           where email = @email);
    end if;
                       

    set @accountProviderDataId = (select id
                                    from ua.accountProviderData
                                   where account = @accountId
                                     and authProvider = @authProviderId
                                     and providerUid = @providerUid);
                                     
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