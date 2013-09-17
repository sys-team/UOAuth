create or replace procedure ua.newAccessToken(@accountClientDataId integer)
begin
    declare @token varchar(256);
    declare @expiresIn integer;
    
    set @token = uuidtostr(util.UDGuid());
    set @expiresIn = 36000;
    
    insert into ua.accountClientDataAccessToken with auto name
    select
        @accountClientDataId as accountClientData,
        @token as accessToken,
        now() as accessTokenTs,
        @expiresIn as accessTokenExpiresIn
    ;
    
    /*update ua.accountClientData
       set accessToken = @token,
           accessTokenTs = now(),
           accessTokenExpiresIn = @expiresIn
     where id = @accountClientDataId;
    */
    
    select @token as accessToken, @expiresIn as expiresIn;
    
end;