create or replace function ua.newAuthCode(@accountId integer, @clientCode varchar(256))
returns varchar(256)
begin
    declare @result varchar(255);
    
    set @result = uuidtostr(newid());
    
    update ua.accountClientData
       set authCode = @result,
           authCodeTs = now(),
           authCodeExpiresIn = 600
     where account =  @accountId
       and client = (select id from ua.client where code = @clientCode);
       
    return @result;

end
;