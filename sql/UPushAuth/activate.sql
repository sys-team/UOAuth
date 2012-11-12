create or replace function upa.activate()
returns xml
begin
    declare @response xml;
    declare @deviceXid uniqueidentifier;
    declare @activationCode long varchar;
    
    set @deviceXid = strtouuid(http_variable('device_id'));
    set @activationCode = isnull(http_variable('activation_code'),'');
    
    if @deviceXid is null or @activationCode = '' then
        set @response = xmlelement('error','activation_code or device_id missing');
        return @response;     
    end if;
    
    if exists(select *
                from upa.device d join upa.activationCode ac on d.id = ac.device
               where d.xid = @deviceXid
                 and ac.cts >= dateadd(mi, -10, now())) then
                 
        update upa.device
           set registered = 1
         where xid = @deviceXid;
         
    else
        call dbo.sa_set_http_header('@HttpStatus', '403');
    end if;
    
    return @response;
end
;