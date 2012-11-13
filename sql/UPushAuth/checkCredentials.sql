create or replace function upa.checkCredentials(
    @clientId long varchar default null,
    @clientSecret long varchar default null,
    @accountCode long varchar default null,
    @accountSecret long varchar default null,
    @redirectUrl long varchar default null
)
returns xml
begin
    declare @response xml;
    declare @xid uniqueidentifier;
    declare @deviceXid long varchar;
    declare @deviceId integer;

    set @clientId = coalesce(@clientId, http_variable('client_id'),'');
    set @clientSecret = coalesce(@clientSecret, http_variable('client_secret'),'');
    set @accountCode = coalesce(@accountCode, http_variable('account_code'),'');
    set @accountSecret = coalesce(@accountSecret, http_variable('account_secret'),'');
    set @redirectUrl = coalesce(@redirectUrl, http_variable('redirect_uri'),'');
    
    set @xid = newid();
    
    insert into upa.checkCredentialsLog with auto name
    select @xid as xid,
           @clientId as clientId,
           @clientSecret as clientSecret,
           @accountCode as accountCode,
           @accountSecret as accountSecret,
           @redirectUrl as redirectUrl;
           
    if @clientId = '' or @accountCode = '' or @accountSecret = '' or @redirectUrl = '' then
    
        set @response = xmlelement('error','client_id, account_code, account_secret or redirect_uri missing');
        
        update upa.checkCredentialsLog
           set response = @response
        where xid = @xid;
        
        return @response;
        
    end if;
    
    set @deviceXid = upa.parseRedirectUrl(@redirectUrl);
    set @deviceId = (select id
                       from upa.device
                      where xid = @deviceXid);
                      
    if exists (select *
                 from upa.device d join upa.deviceClientRegistration dcr on d.id = dcr.device
                                   join upa.client c on dcr.client = c.id
                where d.id = @deviceId
                  and c.code = @clientId
                  and dcr.secret = @accountSecret
                  and dcr.authCode = @accountCode
                  and dcr.cts >= dateadd(mi, -5, now())) then
                  
        set @response = (select xmlelement('device',xmlelement('type', deviceType),
                                                    xmlelement('xid', xid))
                           from upa.device
                          where id = @deviceId);
                  
    else
        set @response = xmlelement('error','Not authorized');
    end if;

    update upa.checkCredentialsLog
       set response = @response
     where xid = @xid;
    
    return @response;
end
;