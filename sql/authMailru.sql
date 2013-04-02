create or replace procedure ua.authMailru(
    @eService long varchar,
    @eAuthCode long varchar,
    @clientCode long varchar
)
begin
    declare @xid uniqueidentifier;

    declare @refreshToken long varchar;
    declare @accessToken long varchar;
    declare @providerResponse long varchar;
    declare @providerResponseXml long varchar;
    declare @providerUid long varchar;
    declare @providerError long varchar;
    
    declare @providerClientId long varchar;
    declare @providerClientSecret long varchar;
    declare @providerRedirectUrl long varchar;
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;
    
    declare @clientId long varchar;
    declare @redirectUrl long varchar;
    
    declare @tmp long varchar;
    declare @proxyUrl long varchar;
    
    set @proxyUrl = 'https://system.unact.ru/utils/proxy.php';
    --set @proxyUrl = 'http://lamac.unact.ru/~sasha/UDUtils/proxy.php';

    select id,
           redirectUrl
      into @clientId, @redirectUrl
      from ua.client
     where code = @clientCode;

    select ap.clientId,
           ap.clientSecret,
           caprd.redirectUrl,
           p.refreshTokenUrl,
           p.accessTokenUrl
      into @providerClientId, @providerClientSecret, @providerRedirectUrl, @refreshTokenUrl, @accessTokenUrl
      from ua.authProvider ap left outer join ua.clientAuthProviderRegData caprd on ap.id = caprd.authProvider
                              join ua.protocol p on p.id = ap.protocol
     where code = @eService
       and caprd.client = @clientId;

    -- refresh & access token
    set @xid = newid();
    
    set @tmp =  'client_id=' + @providerClientId
           + '&client_secret=' + @providerClientSecret
           + '&grant_type=authorization_code'
           + '&code=' + @eAuthCode
           + '&redirect_uri=' + @providerRedirectUrl ;
           
    -- message '@tmp = ', @tmp;
    
    insert into ua.mailruLog with auto name
    select @xid as xid,
           @refreshTokenUrl as url,
           @tmp as request;
           
    set @providerResponse =  mailru.processAuthCode(@proxyUrl,
                                                    @refreshTokenUrl,
                                                    @providerClientId,
                                                    @providerClientSecret,
                                                    'authorization_code',
                                                    @eAuthCode,
                                                    @providerRedirectUrl);
                                                    
                                                    
    update ua.mailruLog
       set response = @providerResponse
     where xid = @xid;
     
    set @providerResponseXml = ua.json2xml(@providerResponse);
    -- message 'mailru reponse = ', @providerResponseXml;
    
    select refreshToken,
           accessToken,
           uid,
           error
      into @refreshToken, @accessToken, @providerUid, @providerError
      from openxml(@providerResponseXml,'/*:response')
            with(refreshToken long varchar '*:refresh_token',
                 accessToken long varchar '*:access_token',
                 uid long varchar '*:x_mailru_vid',
                 error long varchar '*:error');
                 
    if @providerError is null then
    
        set @xid = newid();
        
        set @tmp = @proxyUrl+ '?_address=' +  @accessTokenUrl +'&'
                            + 'method=users.getInfo&app_id=' +  @providerClientId + '&'
                            + 'session_key=' + @accessToken +'&'
                            + 'secure=1&format=xml&'
                            + 'sig=' + mailru.sign(@providerClientSecret,
                                                   @providerClientId,
                                                   'xml',
                                                   'users.getInfo',
                                                   '1',
                                                    @accessToken );
        
        insert into ua.mailruLog with auto name
        select @xid as xid,
               @tmp as url;
        
        set @providerResponseXml = ua.systemProxyGet(@tmp);
        
        update ua.mailruLog
           set response = @providerResponseXml
         where xid = @xid;
        
        if @providerResponseXml like '{"error":%' then
            set @providerError = 'Unknown error';
        else
            select error
              into @providerError
              from openxml(@providerResponseXml,'/*:error')
                   with(error long varchar '*:error_msg');

        end if;
    
        -- message 'mailru reponse = ', @providerResponseXml;
    end if;

    select @refreshToken as refreshToken,
           @providerResponseXml as providerResponseXml,
           @providerUid as providerUid,
           @providerError as providerError;
           
end
;