create or replace function ua.auth(@request long varchar)
returns xml
begin
    declare @response xml;
    declare @service varchar(128);
    declare @authCode varchar(1024);
    declare @refreshToken varchar(1024);
    
    declare @xid uniqueidentifier;
    
    declare @clientId varchar(1024);
    declare @clientSecret varchar(1024);
    declare @refreshTokenUrl long varchar;
    declare @accessTokenUrl long varchar;
    declare @providerResponse long varchar;
    
    set @service = http_variable('e-service');
    set @authCode = http_variable ('e-auth-code');
    set @refreshToken = http_variable('e-refresh-token');
    
    message 'ua.auth @service = ', @service,' @authCode = ', @authCode,' @refreshToken = ', @refreshToken;
    
    if @service not in (select code from ua.authProvider) then
    
        set @response = xmlelement('error','Unknown Auth Provider');
        
    elseif @authCode is null and @refreshToken is null then
    
        set @response = xmlelement('error','e-auth-code and e-refresh-token required');
        
    else
        
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
        
        --set @xid = newid();
        
        case @service
            when 'google' then
                if @authCode is not null then
                
                    set @providerResponse = google.processAuthCode(@refreshTokenUrl,@authCode, @clientId, @clientSecret);
                    
                    set @response = @providerResponse;
                end if;
        
        end case;
    end if;

    return @response;

end
;