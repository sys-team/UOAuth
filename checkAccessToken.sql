create or replace function ua.checkAccessToken(@accessToken varchar(1024))
returns integer
begin
    declare @result integer;
    
    set @result = (select account
                    from ua.accessToken
                   where data = @accessToken
                     and datediff(ss, cts, now()) < expiresIn);
    
    return @result;
end
;