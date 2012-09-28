create or replace procedure ua.newAccessToken(@accountId integer, @clientCode varchar(256))
begin
    declare @token varchar(256);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 3600;
    
    update ua.accountClientData
       set accessToken = @token,
           accessTokenTs = now(),
           accessTokenExpiresIn = @expiresIn
     where account = @accountId
       and client = (select id from client where code = @clientCode);


    select @token as accessToken, @expiresIn as expiresIn;
end
;