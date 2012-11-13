create or replace procedure upa.reisterDeviceForClient(@deviceId integer, @clientId long varchar)
begin
    declare @secret long varchar;
    declare @authCode long varchar;
    declare @cliId integer;
    
    set @secret = uuidtostr(newid());
    set @authCode = uuidtostr(newid());

    set @cliId = (select id
                    from upa.client
                   where code = @clientId);
                   
    delete from upa.deviceClientRegistration
     where client = @cliId
       and device = @deviceId
       and cts < dateadd(mi, -5, now());
       
    insert into upa.deviceClientRegistration with auto name
    select @secret as secret,
           @authCode as authCode,
           @cliId as client,
           @deviceId as device;

    select @secret as secret,
           @authCode as authCode;

end
;
