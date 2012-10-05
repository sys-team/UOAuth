create or replace function ua.checkAccessToken(@accessToken varchar(1024))
returns integer
begin
    declare @result integer;
    
    set @result = (select account
                    from ua.accountClientData
                   where accessToken = @accessToken
                     and datediff(ss, accessTokenTs, now()) < accessTokenExpiresIn);
    
    return @result;
end
;