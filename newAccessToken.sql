create or replace procedure ua.newAccessToken(@accountId integer)
begin
    declare @token varchar(1024);
    declare @expiresIn integer;
    
    set @token = uuidtostr(newid());
    set @expiresIn = 3600;
    
    insert into ua.accessToken with auto name
    select @token as data,
           @expiresIn as expiresIn,
           @accountId as account;

    select @token as accessToken, @expiresIn as expiresIn;
end
;