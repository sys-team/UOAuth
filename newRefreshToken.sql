create or replace procedure ua.newRefreshToken(@accountId integer, @clientCode varchar(256))
begin
    declare @token varchar(1024);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 6000000;

    update ua.accountClientData
       set refreshToken = @token,
           refreshTokenTs = now(),
           refreshTokenExpiresIn = @expiresIn
     where account = @accountId
       and client = (select id from client where code = @clientCode);

    select @token as refreshToken, @expiresIn as expiresIn;
    
end
;