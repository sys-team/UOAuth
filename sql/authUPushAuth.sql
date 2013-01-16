create or replace procedure ua.authUPushAuth(
    @eAuthCode long varchar,
    @clientCode long varchar,
    @eRedirectUrl long varchar,
    @accessTokenUrl long varchar
)
begin
    declare @xid uniqueidentifier;
    
    declare @providerResponseXml xml;
    declare @providerUid long varchar;
    declare @providerError long varchar;
    declare @accountCode long varchar;
    declare @accountSecret long varchar;

    
    select left(@eAuthCode, locate(@eAuthCode,'_')-1),
           substr(@eAuthCode,locate(@eAuthCode,'_')+1)
      into @accountCode, @accountSecret;

    --message 'ua.authUPushAuth ',@clientCode,' ', @accountCode,' ', @accountSecret,' ', @eRedirectUrl;
    
    if @accessTokenUrl is null then
        set @providerResponseXml = xmlelement('response',upa.checkCredentials(@clientCode,'', @accountCode, @accountSecret, @eRedirectUrl));
    else
        set @providerResponseXml = ua.systemProxyGet(@systemProxyUrl+ '?_address=' + @accessTokenUrl +
                                   '&client_id=' + @clientCode + '&account_code=' + @accountCode +
                                   '&account_secret=' + @accountSecret + '&redirect_uri=' + @eRedirectUrl);
    end if;
    
    --message 'ua.authUPushAuth @providerResponseXml = ', @providerResponseXml;
    
    set @providerError = (select error
                            from openxml(@providerResponseXml ,'/*:response/*:error')
                                 with(error long varchar '.'));
                                 
    --message 'ua.authUPushAuth @providerError = ', @providerError;

    select '' as refreshToken,
           @providerResponseXml as providerResponseXml,
           @providerUid as providerUid,
           @providerError as providerError;
   
end
;