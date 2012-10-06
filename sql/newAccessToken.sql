create or replace procedure ua.newAccessToken(@accountClientDataId integer)
begin
    declare @token varchar(256);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 36000;
    
    update ua.accountClientData
       set accessToken = @token,
           accessTokenTs = now(),
           accessTokenExpiresIn = @expiresIn
     where id = @accountClientDataId;
        
    select @token as accessToken, @expiresIn as expiresIn;
    
end
;