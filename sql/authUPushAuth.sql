create or replace procedure ua.authUPushAuth(
    @eAuthCode long varchar,
    @clientCode long varchar,
    @eRedirectUrl long varchar
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
    
    set @providerResponseXml = xmlelement('response',upa.checkCredentials(@clientCode,'', @accountCode, @accountSecret, @eRedirectUrl));
    
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