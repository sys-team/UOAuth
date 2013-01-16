--/auth : первичная регистрация по auth_code из внешнего сервиса
--(в ответ выпускаем наши access_token и refresh_token и выдаем code, для их получения)
--
--параметры:
--client_id - наш id для нашего сервиса
--redirect_uri - uri сервиса-инициатора, способный обработать ответ
--access_type = {offline} (опционально)
--auth_type = {external} (опционально)
--e_service={google, facebook, vk} (опционально, только при auth-type = external)
--e_code = внешний auth_code (опционально, только при auth-type = external)
--тип запроса - GET или POST
--
--ответ - 302 переход на redirect_uri с параметром code = {наш auth_code}
--обработка ошибок - переход на redirect_uri с параметром error={описание ошибки} (например access_denied)

create or replace function ua.auth()
returns xml
begin
    declare @response xml;
    declare @error long varchar;
    
    declare @eService long varchar;
    declare @eAuthCode long varchar;
    declare @eRedirectUrl long varchar;
    
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;
    declare @providerResponse long varchar;
    declare @providerResponseXml xml;
    declare @providerUid long varchar;
    declare @providerError long varchar;
    
    declare @providerClientId long varchar;
    declare @providerClientSecret long varchar;
    declare @providerRedirectUrl long varchar;
    
    declare @refreshToken long varchar;
    declare @accessToken long varchar;
    declare @audience long varchar;
    
    declare @xid uniqueidentifier;
    
    declare @clientCode long varchar;
    declare @clientId integer;
    declare @redirectUrl long varchar;

    declare @accountId integer;
    declare @accountClientDataId integer;
    declare @needsRefreshToken BOOL;
    
    declare @url long varchar;

    declare @uAuthCode long varchar;
    declare @proxyUrl long varchar;
    -------
    
    set @proxyUrl = 'https://system.unact.ru/utils/proxy.php';
    
    set @eService = http_variable('e_service');
    set @eAuthCode = http_variable('e_code');
    set @clientCode = http_variable('client_id');
    set @eRedirectUrl = http_variable('redirect_uri');

    
    --message 'ua.auth @eService = ', @eService,' @eAuthCode = ', @eAuthCode,' @clientCode = ', @clientCode;
    
    if @eService not in (select code from ua.authProvider) then        
        set @response = xmlelement('error','Unknown e_service');
        
        return @response;
    end if;
        
    if @eAuthCode is null then
        
        set @response = xmlelement('error','e_code required');
        return @response;
    end if;
    
    select
        id,
        redirectUrl,
        needsRefreshToken
    into @clientId, @redirectUrl, @needsRefreshToken
    from ua.client
    where code = @clientCode;
    
    if @clientId is null then
        set @response = xmlelement('error','Unknown client_id');
        return @response;
    end if;
        
    set @response = xmlelement('redirect-url', @redirectUrl);
    
    select refreshTokenUrl,
           accessTokenUrl
      into @refreshTokenUrl, @accessTokenUrl
      from ua.authProvider
     where code = @eService;

    begin
        declare http_status_err exception for sqlstate 'WW052';
        
        select ap.clientId,
               ap.clientSecret,
               caprd.redirectUrl
          into @providerClientId, @providerClientSecret, @providerRedirectUrl
          from ua.authProvider ap left outer join ua.clientAuthProviderRegData caprd on ap.id = caprd.authProvider
         where ap.code = @eService
           and caprd.client = @clientId;

        case 
            when @eService in ('google','googlei') then
                
                -- get access token
                set @xid = newid();
                
                insert into ua.googleLog with auto name
                select @xid as xid,
                       @refreshTokenUrl as url,
                       'code='+@eAuthCode+'&client_id='+@providerClientId+'&client_secret='+@providerClientSecret
                        +'&grant_type=authorization_code'+'&redirect-uri='+isnull(@providerRedirectUrl,'urn:ietf:wg:oauth:2.0:oob') as request;
                
                
                set @providerResponse = google.processAuthCode(@proxyUrl + '?_address=' +@refreshTokenUrl,
                                                               @eAuthCode, @providerClientId, @providerClientSecret,
                                                               isnull(@providerRedirectUrl,'urn:ietf:wg:oauth:2.0:oob'));

                
                update ua.googleLog
                   set response = @providerResponse
                 where xid = @xid;  
                
                set @providerResponseXml = ua.json2xml(@providerResponse);
                
                --message 'ua.auth @providerResponseXml = ', @providerResponseXml;
                
                select refreshToken,
                       accessToken
                  into @refreshToken, @accessToken  
                  from openxml(@providerResponseXml ,'/*:response')
                       with (refreshToken varchar(1024) '*:refresh_token', accessToken varchar(1024) '*:access_token');
                       
                -- check application
                set @xid = newid();
                
                insert into ua.googleLog with auto name
                select @xid as xid,
                       @accessTokenUrl+'/tokeninfo?access_token='+@accessToken as url;
                       
                set @providerResponse =  ua.systemProxyGet(@proxyUrl+ '?_address=' + @accessTokenUrl+'/tokeninfo?access_token='+@accessToken);
                --set @providerResponse = google.googleapisGet(@accessTokenUrl+'/tokeninfo?access_token='+@accessToken);
                
                update ua.googleLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                set @providerResponseXml = ua.json2xml(@providerResponse);
                
                select audience
                  into @audience
                  from openxml(@providerResponseXml ,'/*:response')
                       with (audience varchar(1024) '*:audience');

                if @audience <> @providerClientId then
                    
                    set @response = xmlconcat(xmlelement('error','Provider application mismatch'), @response);
                    return @response;
                end if;

                -- user info
                set @xid = newid();
                
                insert into ua.googleLog with auto name
                select @xid as xid,
                       @accessTokenUrl+'/userinfo?access_token='+@accessToken as url;
                       
                set @providerResponse = ua.systemProxyGet(@proxyUrl+ '?_address=' + @accessTokenUrl+'/userinfo?access_token='+@accessToken);
                --set @providerResponse = google.googleapisGet(@accessTokenUrl+'/userinfo?access_token='+@accessToken);
                
                update ua.googleLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                --set @providerResponseXml = ua.json2xml(csconvert(@providerResponse,'utf-8','windows-1251'));
                set @providerResponseXml = ua.json2xml(@providerResponse);
                set @providerResponseXml = csconvert(@providerResponseXml,'char_charset','utf-8');
                
            when @eService = 'facebook' then
            
                set @url = @refreshTokenUrl + '&client_id=' + @providerClientId
                                            + '&client_secret=' + @providerClientSecret
                                            + '&redirect_uri=' + @providerRedirectUrl
                                            + '&code=' +  @eAuthCode;
                                            
                set @xid = newid();
                
                insert into ua.fbLog with auto name
                select @xid as xid,
                       @url as url;
            
                -- acesss_token
                set @providerResponse = ua.systemProxyGet(@proxyUrl + '?_address=' + @url);
                                               
                update ua.fbLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                set @accessToken = (select top 1
                                           varValue
                                      from openstring(value @providerResponse)
                                           with(varName long varchar, varValue long varchar)
                                           option (delimited by '=' row delimited by '&') as t
                                     where varName = 'access_token');
                                     
                if @accessToken is null then
                    set @response = xmlconcat(xmlelement('error','Authorization error'), @response);
                    return @response;
                end if;
                
                
                --'@mp:xmltext'
                -- user data            
                set @url = @accessTokenUrl + '&access_token=' + @accessToken;
                
                set @xid = newid();
                
                insert into ua.fbLog with auto name
                select @xid as xid,
                       @url as url;
            
                set @providerResponse = ua.systemProxyGet(@proxyUrl + '?_address=' + @url);
                                               
                update ua.fbLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                set @providerResponseXml = ua.json2xml(@providerResponse);
                -- message 'fbdata = ', @providerResponseXml;
                
            when @eService = 'vk' then
            
                -- access token
                set @url = @refreshTokenUrl + '?client_id=' + @providerClientId
                            + '&client_secret=' + @providerClientSecret
                            + '&code=' +  @eAuthCode
                            + '&redirect_uri=' + @providerRedirectUrl;
                                            
                set @xid = newid();
                
                insert into ua.vkLog with auto name
                select @xid as xid,
                       @url as url;
            
                -- acesss_token
                set @providerResponse = vk.processAuthCode(@refreshTokenUrl,@eAuthCode, @providerClientId, @providerClientSecret, @providerRedirectUrl);
                                               
                update ua.vkLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                set @providerResponseXml = ua.json2xml(@providerResponse);
                
                select access_token,
                       user_id
                  into @accessToken, @providerUid
                  from openxml(@providerResponseXml, '/*:response')
                       with(access_token long varchar '*:access_token', user_id long varchar '*:user_id');
                       
                -- user data
                
                set @url = @accessTokenUrl +'?uids=' + @providerUid+'&access_token='+ @accessToken +'&fields=uid,first_name,last_name,contacts';

                set @providerResponseXml = vk.get(@url);
                 
                --message 'vkdata = ', @providerResponseXml;
                
            when @eService = 'mailru' then
            
                select refreshToken,
                       providerResponseXml,
                       providerUid,
                       providerError
                  into @refreshToken, @providerResponseXml, @providerUid, @providerError
                  from ua.authMailru(@eService, @eAuthCode, @clientCode);
                
            when @eService = 'odks' then
            
                select refreshToken,
                       providerResponseXml,
                       providerUid,
                       providerError
                  into @refreshToken, @providerResponseXml, @providerUid, @providerError
                  from ua.authOdks(@eService, @eAuthCode, @clientCode);
                  
            when @eService = 'emailAuth' then
            
                select refreshToken,
                       providerResponseXml,
                       providerUid,
                       providerError
                  into @refreshToken, @providerResponseXml, @providerUid, @providerError
                  from ua.authEMailAuth(@eAuthCode, @accessTokenUrl);
                  
            when @eService = 'UPushAuth' then
            
                select refreshToken,
                       providerResponseXml,
                       providerUid,
                       providerError
                  into @refreshToken, @providerResponseXml, @providerUid, @providerError
                  from ua.authUPushAuth(@eAuthCode, @clientCode, @eRedirectUrl, @accessTokenUrl);
                  
        end case;
        
        if @providerError is not null then
            set @response = xmlconcat(xmlelement('error',@providerError), @response);
            return @response;
        end if;
        
        set @accountClientDataId = ua.registerAccount(@eService,
                                                      @clientCode,
                                                      @refreshToken,
                                                      @providerResponseXml);
        
        set @response =  xmlconcat( if (@needsRefreshToken = '1')
            then xmlelement('auth-code', ua.newAuthCode(@accountClientDataId))
            else (select xmlelement('access-token', accessToken) from ua.newAccessToken(@accountClientDataId))
        endif, @response);
    
        
    exception
        when others then
            set @error = errormsg();
            message 'ua.auth error = ', @error;
        
            set @response = xmlconcat(xmlelement('error',@error), @response);
            return @response;

    end;
   
    return @response;

end
;