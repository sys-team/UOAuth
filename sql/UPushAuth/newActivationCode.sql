create or replace function upa.newActivationCode(@deviceId integer)
returns long varchar
begin
    declare @result long varchar;
    
    set @result = uuidtostr(newid());

    delete from upa.activationCode
     where device = @deviceId
       and cts < dateadd(mi, -10, now());
    
    insert into upa.activationCode with auto name
    select @deviceId as device,
           @result as code;
     
    return @result;

end
;