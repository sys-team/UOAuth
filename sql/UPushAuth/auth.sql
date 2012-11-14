create or replace function upa.auth()
returns xml
begin
    declare @response xml;
    declare @clientId long varchar;
    declare @redirectUrl long varchar;
    declare @xid uniqueidentifier;
    declare @deviceXid long varchar;
    declare @deviceId integer;
    declare @secret long varchar;
    declare @authCode long varchar;
    declare @id integer;
    
    set @clientId = isnull(http_variable('client_id'),'');
    set @redirectUrl = isnull(http_variable('redirect_uri'),'');
    
    set @xid = newid();
    
    insert into upa.authLog with auto name
    select @xid as xid,
           @clientId as clientId,
           @redirectUrl as redirectUrl;
    
    if @clientId = '' or @redirectUrl = '' then
        set @response = xmlelement('error','client_id or redirect_uri missing');
        
        update upa.authLog
           set response = @response
         where xid = @xid;
     
        return @response;     
    end if;
    
    if not exists (select *
                     from upa.client
                    where code = @clientId) then
                    
        set @response = xmlelement('error','unknown client_id');
        
        update upa.authLog
           set response = @response
         where xid = @xid;
     
        return @response;     
    end if;
       
    set @deviceXid = upa.parseRedirectUrl(@redirectUrl);
    set @deviceId = (select id
                       from upa.device
                      where xid = @deviceXid);
        
    if exists (select *
                 from upa.device
                where id = @deviceId
                  and registered = 1) then
                  
        select secret,
               authCode,
               id
          into @secret, @authCode, @id
          from upa.reisterDeviceForClient(@deviceId, @clientId);
          
        set @response = xmlconcat(xmlelement('code', @authCode), xmlelement('id', @id));
        
        call upa.pushMessageToDevice(@deviceId, '"client_secret":{"value":"' + @secret + '","id":"'+cast(@id as varchar(24)) + '"}');
         
    else
        set @response = xmlelement('error','device_id not registered yet');
    end if;
    
    
    update upa.authLog
       set response = @response
     where xid = @xid;
    
    return @response;
end
;