create or replace procedure ua.newRefreshToken(@accountClientDataId integer)
begin
    declare @token varchar(1024);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 6000000;

    update ua.accountClientData
       set refreshToken = @token,
           refreshTokenTs = now(),
           refreshTokenExpiresIn = @expiresIn,
           authCode = null,
           authCodeTs = null
     where id = @accountClientDataId;

    select @token as refreshToken, @expiresIn as expiresIn;
    
end
;