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
    
    declare @eService varchar(128);
    declare @eAuthCode varchar(1024);
    
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;
    declare @providerResponse long varchar;
    declare @providerResponseXml xml;
    
    declare @providerClientId varchar(1024);
    declare @providerClientSecret varchar(1024);
    
    declare @refreshToken varchar(1024);
    declare @accessToken varchar(1024);
    declare @audience varchar(1024);
    
    declare @xid uniqueidentifier;
    
    declare @clientCode varchar(256);
    declare @clientId integer;
    declare @redirectUrl long varchar;

    declare @accountId integer;

    declare @uAuthCode varchar(256);
    -------
    
    set @eService = http_variable('e_service');
    set @eAuthCode = http_variable('e_code');
    set @clientCode = http_variable('client_id');
    
    --message 'ua.auth @eService = ', @eService,' @eAuthCode = ', @eAuthCode,' @clientCode = ', @clientCode;
    
    if @eService not in (select code from ua.authProvider) then        
        set @response = xmlelement('error','Unknown e_service');
        
        return @response;
    end if;
        
    if @eAuthCode is null then
        
        set @response = xmlelement('error','e_code required');
        return @response;
    end if;
    
    select id,
           redirectUrl
      into @clientId, @redirectUrl
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
        
        select clientId,
               clientSecret
          into @providerClientId, @providerClientSecret
         from ua.authProvider
        where code = @eService;

        case @eService
            when 'google' then
                
                -- get access token
                set @xid = newid();
                
                insert into ua.googleLog with auto name
                select @xid as xid,
                       @refreshTokenUrl as url,
                       'code='+@eAuthCode+'&client_id='+@providerClientId+'&client_secret='+@providerClientSecret as request;
                    
                set @providerResponse = google.processAuthCode(@refreshTokenUrl, @eAuthCode, @providerClientId, @providerClientSecret);
                
                update ua.googleLog
                   set response = @providerResponse
                 where xid = @xid;  
                
                set @providerResponseXml = ua.json2xml(@providerResponse);
                
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
        
                set @providerResponse = google.googleapisGet(@accessTokenUrl+'/tokeninfo?access_token='+@accessToken);
                
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
                       
                set @providerResponse = google.googleapisGet(@accessTokenUrl+'/userinfo?access_token='+@accessToken);
                
                update ua.googleLog
                   set response = @providerResponse
                 where xid = @xid;
                 
                set @providerResponseXml = ua.json2xml(csconvert(@providerResponse,'utf-8','windows-1251'));
                
                set @providerResponseXml = csconvert(@providerResponseXml,'char_charset','utf-8');
                
 
        
        end case;
        
        set @accountId = ua.registerAccount(@eService, @clientCode, @refreshToken, @providerResponseXml);
        set @uAuthCode = ua.newAuthCode(@accountId, @clientCode);
         
        set @response =  xmlconcat(xmlelement('auth-code', @uAuthCode), @response);
        
    exception
        when http_status_err then
        
            set @error = errormsg();
            set @response = xmlconcat(xmlelement('error',@error), @response);
            return @response;
        when others then
            resignal;
    end;
    

    return @response;

end
;