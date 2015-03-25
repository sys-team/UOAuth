create or replace procedure ua.authOdks(
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
    declare @providerClientPublicKey long varchar;
    declare @providerRedirectUrl long varchar;
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;

    declare @clientId long varchar;
    declare @redirectUrl long varchar;
    declare @needsRefreshToken integer;

    declare @tmp long varchar;
    declare @proxyUrl long varchar;

    set @proxyUrl = util.getUserOption('http.proxy.url');

    select id,
           redirectUrl
      into @clientId, @redirectUrl
      from ua.client
     where code = @clientCode;

    select ap.clientId,
           ap.clientSecret,
           caprd.redirectUrl,
           p.refreshTokenUrl,
           p.accessTokenUrl,
           ap.clientPublicKey
      into @providerClientId, @providerClientSecret, @providerRedirectUrl, @refreshTokenUrl, @accessTokenUrl, @providerClientPublicKey
      from ua.authProvider ap left outer join ua.clientAuthProviderRegData caprd on ap.id = caprd.authProvider
                              join ua.protocol p on p.id = ap.protocol
     where ap.code = @eService
       and caprd.client = @clientId;

    -- refresh & access token
    set @xid = newid();

    set @tmp = 'code=' + @eAuthCode + '&'
             + 'redirect_uri=' + @providerRedirectUrl +'&'
             + 'grant_type=authorization_code&'
             + 'client_id=' + @providerClientId + '&'
             + 'client_secret=' + @providerClientSecret;


    insert into ua.odksLog with auto name
    select @xid as xid,
           @refreshTokenUrl as url,
           @tmp as request;


    set @providerResponse = odks.processAuthCode(@proxyUrl,
                                                 @refreshTokenUrl,
                                                 @eAuthCode,
                                                 @providerRedirectUrl,
                                                 @providerClientId,
                                                 @providerClientSecret);

    update ua.odksLog
       set response = @providerResponse
     where xid = @xid;

    set @providerResponseXml = ua.json2xml(@providerResponse);

    select refreshToken,
           accessToken
      into @refreshToken, @accessToken
      from openxml(@providerResponseXml ,'/*:response')
           with(refreshToken long varchar '*:refresh_token', accessToken long varchar '*:access_token');

    if @accessToken is not null then

        set @tmp = @accessTokenUrl + '?application_key=' + @providerClientPublicKey + '&'
                                   + 'format=XML&' +
                                   + 'sig=' + odks.sign(@accessToken, @providerClientSecret,@providerClientPublicKey) + '&'
                                   + 'access_token=' + @accessToken;

        set @providerResponseXml = ua.systemProxyGet(@tmp);

        --message 'odks @providerResponseXml = ', @providerResponseXml;

        select uid
          into @providerUid
          from openxml(@providerResponseXml, '/*:user')
               with(uid long varchar '*:uid');

        if @providerUid is null then
            set @providerError = 'Authorization Error';
        end if;

    else
        set @providerError = 'Authorization Error';
    end if;


    select @refreshToken as refreshToken,
           @providerResponseXml as providerResponseXml,
           @providerUid as providerUid,
           @providerError as providerError;

end
;
