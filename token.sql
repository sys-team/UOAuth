--/token : получение нашего access_token по нашему refresh_token или access_token и refresh_token
--(в случае access_type = offline) по нашему code
--
--параметры:
--refresh_token = refresh-token, полученный с помощью code (опционально)
--code = code, полученный от нашего auth (опционально)
--client_id = наш id для нашего сервиса
--client_secret = секретный ключ для нашего сервиса
--типа запроса - POST
--ответ:
--/*/access-token [text()] [@expire-after]
--/*/refresh-token [text()] (в случае access_type = offline)
--/*/roles[role[text()]] - авторизованные роли

create or replace function ua.token()
returns xml
begin
    declare @response xml;

    declare @refreshToken varchar(256);
    declare @refreshTokenExpiresIn integer;
    declare @authCode varchar(256);
    declare @clientCode varchar(256);
    declare @clientSecret varchar(256);
    
    declare @accountId integer;
    declare @accountClientDataId integer; 
    declare @accessToken varchar(1024);
    declare @accessTokenExpiresIn integer;
    -------
    set @refreshToken = http_variable('refresh_token');
    set @authCode = http_variable('code');
    set @clientCode = http_variable('client_id');
    set @clientSecret = http_variable('client_secret');
    
    select c.id,
           acd.id
      into @accountId, @accountClientDataId
      from ua.accountClientData acd join ua.client c on acd.client = c.id
     where (acd.refreshToken = isnull(@refreshToken,'')
       and datediff(ss, acd.refreshTokenTs, now()) < acd.refreshTokenExpiresIn
        or acd.authCode = isnull(@authCode,'')
       and datediff(ss, acd.authCodeTs, now()) < acd.authCodeExpiresIn)
       and c.code = @clientCode
       and c.secret = @clientSecret;
                         
    if @accountId is null or @accountClientDataId is null then
        set @response = xmlelement('error','Not authorized');
        return @response;
    end if;
    
    if @refreshToken is null then
        select refreshToken, 
               expiresIn
          into @refreshToken, @refreshTokenExpiresIn
          from ua.newRefreshToken(@accountClientDataId);
    end if;
    
    select accessToken, 
           expiresIn
      into @accessToken, @accessTokenExpiresIn
      from ua.newAccessToken(@accountClientDataId);    

    set @response = xmlelement('access-token', xmlattributes(@accessTokenExpiresIn as "expire-after"), @accessToken)
                  + if @refreshTokenExpiresIn is not null then xmlelement('refresh-token', @refreshToken) else '' endif
                  + ua.accountRoles(@accountId);
                        
    return @response;

end
;