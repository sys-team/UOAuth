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
    declare @needsRefreshToken integer;
    
    declare @tmp long varchar;

    select id,
           redirectUrl,
           needsRefreshToken
      into @clientId, @redirectUrl, @needsRefreshToken
      from ua.client
     where code = @clientCode;

    select ap.clientId,
           ap.clientSecret,
           caprd.redirectUrl,
           ap.refreshTokenUrl,
           ap.accessTokenUrl
      into @providerClientId, @providerClientSecret, @providerRedirectUrl, @refreshTokenUrl, @accessTokenUrl
      from ua.authProvider ap left outer join ua.clientAuthProviderRegData caprd on ap.id = caprd.authProvider
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
           
    set @providerResponse =  mailru.processAuthCode('https://system.unact.ru/utils/proxy.php',
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
      into 
      from openxml(@providerResponseXml,'/*:response')
            with(refreshToken long varchar '*:refresh_token',
                 accessToken long varchar '*:access_token',
                 uid long varchar '*:x_mailru_vid');


    select @refreshToken as refreshToken,
           @providerResponseXml as providerResponseXml,
           @providerUid as providerUid;
           
end
;