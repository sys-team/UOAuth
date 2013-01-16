create or replace procedure ua.authEMailAuth(
    @eAuthCode long varchar,
    @accessTokenUrl long varchar
)
begin
    declare @response xml;
    declare @providerError long varchar;
    
    declare @userId integer;
    declare @login long varchar;
    declare @email long varchar;
    
    if @accessTokenUrl is null then
        select id,
               username,
               email
          into @userId, @login, @email
          from dbo.udUser
         where authCode = @eauthCode
           and authCodeTs > dateadd(hour, -5, now())
           and confirmed = 1;
    else
        -- query roles
        set @response = ua.systemProxyGet(@systemProxyUrl+ '?_address=' + @accessTokenUrl + '&access_token=' + @eauthCode);
        
        select id,
               username,
               email
          into @userId, @login, @email
          from openxml(@response,'/*:response/*:account')
               with(id long varchar '*:id', username long varchar '*:username', email long varchar '*:email');
 
    end if;
     
    if @userId is null then
        set @providerError = 'Not Authorized';
    end if;

    select null as refreshToken,
           xmlelement('response', xmlelement('login', @login),
                                  xmlelement('email', @email),
                                  xmlelement('uid', @userId)) as providerResponseXml,
           @userId as providerUid,
           @providerError as providerError;
           
end
;