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

create or replace function ua.token(
    @refreshToken long varchar default http_variable('refresh_token'),
    @authCode long varchar default http_variable('code'),
    @clientCode long varchar default http_variable('client_id'),
    @clientSecret long varchar default http_variable('client_secret')
)
returns xml
begin
    declare @response xml;

    declare @refreshTokenExpiresIn integer;
    declare @accountId integer;
    declare @accountClientDataId integer; 
    declare @accessToken varchar(1024);
    declare @accessTokenExpiresIn integer;
    -------

    --message 'ua.token @refreshToken = ',  @refreshToken;
    --message 'ua.token @authCode = ',  @authCode;
    --message 'ua.token @clientCode = ',  @clientCode;
    --message 'ua.token @clientSecret = ',  @clientSecret;
    
    select acd.account,
           acd.id
      into @accountId, @accountClientDataId
      from ua.accountClientData acd join ua.client c on acd.client = c.id
     where ((acd.refreshToken = isnull(@authCode,'') or acd.refreshToken = isnull(@refreshToken,''))
       and datediff(ss, acd.refreshTokenTs, now()) < acd.refreshTokenExpiresIn
        or (acd.authCode = isnull(@authCode,'') or acd.authCode = isnull(@refreshToken,''))
       and datediff(ss, acd.authCodeTs, now()) < acd.authCodeExpiresIn)
       and c.code = @clientCode
       and c.secret = @clientSecret;
       
    --message 'ua.token @accountId = ',  @accountId;   
                         
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