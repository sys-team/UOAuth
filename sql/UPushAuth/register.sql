create or replace function upa.register()
returns xml
begin

    declare @response xml;
    declare @pushToken long varchar;
    declare @deviceType long varchar;
    declare @deviceXid uniqueidentifier;
    declare @deviceId integer;
    declare @activationCode long varchar;
    
    set @pushToken = isnull(http_variable('push_token'),'');
    set @deviceType = isnull(http_variable('device_type'),'');
    
    if @pushToken = '' or @deviceType = '' then
        set @response = xmlelement('error','push_token or device_type missing');
        return @response;
    end if;
    
    select xid,
           id
      into @deviceXid, @deviceId
      from upa.device
     where pushToken = @pushToken;
                       
    if @deviceXid is null then
    
        set @deviceXid = newid();
        
        insert into upa.device with auto name
        select @deviceXid as xid,
               @pushToken as pushToken,
               @deviceType as deviceType;
               
        set @deviceId = @@identity;
    
    end if;
    
    set @response = xmlelement('device_id', @deviceXid);
    
    if (select registered
          from upa.device
         where id = @deviceId) = 0 then
         
        set @response = xmlconcat(@response, xmlelement('activation_needed', 'true'));
        
        set @activationCode = upa.newActivationCode(@deviceId);
        
        call upa.pushMessageToDevice(@deviceId, '"activation_code":"' + @activationCode + '"');
        
    end if;
    
    return @response;
end
;