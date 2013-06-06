create or replace function ua.newAuthCode(@accountClientDataId integer)
returns varchar(256)
begin
    declare @result varchar(255);
    
    set @result = uuidtostr(util.UDGuid());
    
   update ua.accountClientData
       set authCode = @result,
           authCodeTs = now(),
           authCodeExpiresIn = 600
     where id = @accountClientDataId;
       
    return @result;

end
;