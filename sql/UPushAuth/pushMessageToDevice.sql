create or replace procedure upa.pushMessageToDevice(@deviceId integer, @message long varchar)
begin
    declare @pushToken long varchar;
    declare @response long varchar;
    declare @xid uniqueidentifier;
    
    set @pushToken = (select pushToken
                        from upa.device
                       where id = @deviceId);
                       
    if @pushToken is null then
        return;
    end if;
    
    set @xid = newid();
    
    set @message = '{"aps":{},"unact":{' + @message + '}}}';
    
    insert into upa.pushMessageLog with auto name
    select @xid as xid,
           @pushToken as pushToken,
           @message as msg;
    
    set @response = upa.pushNotification('http://apns.unact.ru/geotracing-dev', @pushToken, @message);
    
    update upa.pushMessageLog
       set response = @response
     where xid = @xid;

end
;
