create or replace procedure ua.newRefreshToken(@accountId integer)
begin
    declare @token varchar(1024);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 999999999;

    update ua.account
       set uRefreshToken = @token,
           uRefreshTokenTs = now(),
           uRefreshTokenExpiresIn = @expiresIn
     where id = @accountId;

    select @token as refreshToken, @expiresIn as expiresIn;
    
end
;