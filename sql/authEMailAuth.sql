create or replace procedure ua.authEMailAuth(
    @eAuthCode long varchar
)
begin

    declare @providerError long varchar;
    
    declare @userId integer;
    declare @login long varchar;
    declare @email long varchar;
    
    select id,
           username,
           email
      into @userId, @login, @email
      from dbo.udUser
     where authCode = @eauthCode
       and authCodeTs > dateadd(hour, -5, now())
       and confirmed = 1;
     
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