create or replace function ua.auth(@request long varchar)
returns xml
begin
    declare @response xml;
    declare @service varchar(128);
    declare @authCode varchar(1024);
    declare @refreshToken varchar(1024);
    declare @accessToken varchar(1024);
    declare @audience varchar(1024);
    
    declare @xid uniqueidentifier;
    
    declare @clientId varchar(1024);
    declare @clientSecret varchar(1024);
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;
    declare @providerResponse long varchar;
    declare @providerResponseXml xml;
    
    declare @accountId integer;
    declare @uRefreshToken varchar(1024);
    declare @uRefreshTokenExpiresIn integer;
    
    set @service = http_variable('e-service');
    set @authCode = http_variable ('e-auth-code');
    set @refreshToken = http_variable('e-refresh-token');
    
    --message 'ua.auth @service = ', @service,' @authCode = ', @authCode,' @refreshToken = ', @refreshToken;
    
    if @service not in (select code from ua.authProvider) then
        set @response = xmlelement('error','Unknown Auth Provider');
        return @response;
    end if;
        
    if @authCode is null and @refreshToken is null then
        set @response = xmlelement('error','e-auth-code or e-refresh-token required');
    end if;
        
    select refreshTokenUrl,
           accessTokenUrl
      into @refreshTokenUrl, @accessTokenUrl
      from ua.authProvider
     where code = @service;
     
    select top 1
           clientId,
           clientSecret
      into @clientId, @clientSecret
     from ua.clientSecret;
    
    begin
        declare http_status_err exception for sqlstate 'WW052';
        
        case @service
            when 'google' then
                -- get access token
                if @authCode is not null then
                    set @xid = newid();
                    
                    insert into ua.googleLog with auto name
                    select @xid as xid,
                           @refreshTokenUrl as url,
                           'code='+@authCode+'&client_id='+@clientId+'&client_secret='+@clientSecret as request;
                        
                    set @providerResponse = google.processAuthCode(@refreshTokenUrl, @authCode, @clientId, @clientSecret);
                    
                    update ua.googleLog
                       set response = @providerResponse
                     where xid = @xid;  
                    
                    set @providerResponseXml = ua.json2xml(@providerResponse);
                    
                    select refreshToken,
                           accessToken
                      into @refreshToken, @accessToken  
                      from openxml(@providerResponseXml ,'/*:response')
                           with (refreshToken varchar(1024) '*:refresh_token', accessToken varchar(1024) '*:access_token');
                           
                end if;
                
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

                if @audience <> @clientId then
                    set @response = xmlelement('error','Application mismatch');
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
                
                set @accountId = ua.registerAccount(@service, @refreshToken, @providerResponseXml);
                select refreshToken,
                       expiresIn
                  into @uRefreshToken, @uRefreshTokenExpiresIn
                  from ua.newRefreshToken(@accountId);
                 
                set @response =  xmlelement('refresh-token',xmlattributes(@uRefreshTokenExpiresIn as "expire-after"),@uRefreshToken);
        
        end case;
        
    exception
        when http_status_err then
            set @response = xmlelement('error',errormsg());
            
        when others then
            resignal;
    end;
    

    return @response;

end
;