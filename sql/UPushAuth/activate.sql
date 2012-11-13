create or replace function upa.activate()
returns xml
begin
    declare @response xml;
    declare @deviceXid uniqueidentifier;
    declare @activationCode long varchar;
    declare @xid uniqueidentifier;
    
    set @deviceXid = strtouuid(http_variable('device_id'));
    set @activationCode = isnull(http_variable('activation_code'),'');
    
    set @xid = newid();
    
    insert into upa.activateLog with auto name
    select @xid as xid,
           @deviceXid as deviceId,
           @activationCode as activationCode;
    
    if @deviceXid is null or @activationCode = '' then
        set @response = xmlelement('error','activation_code or device_id missing');
        return @response;     
    end if;
    
    if exists(select *
                from upa.device d join upa.activationCode ac on d.id = ac.device
               where d.xid = @deviceXid
                 and ac.code = @activationCode
                 and ac.cts >= dateadd(mi, -10, now())) then
                 
        update upa.device
           set registered = 1
         where xid = @deviceXid;
         
        set @response = xmlelement('activate','yes');
         
    else
        call dbo.sa_set_http_header('@HttpStatus', '403');
        set @response = xmlelement('activate','no');
    end if;
    
    update upa.activateLog
       set response = @response
     where xid = @xid;
    
    return @response;
end
;