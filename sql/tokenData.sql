create or replace function ua.tokenData(@accessToken long varchar)
returns xml
begin
    declare @result xml;

    set @result = (
        select xmlelement('token'
                , xmlelement('ts', accessTokenTs)
                , xmlelement('expiresIn',
                    accessTokenExpiresIn - datediff(ss, accessTokenTs, now())
                )
            )
        from (
            select accessTokenTs, accessTokenExpiresIn
                from ua.accountClientData
                where accessToken = @accessToken
            union all
            select accessTokenTs, accessTokenExpiresIn
                from ua.accountClientDataAccessToken
                where accessToken = @accessToken
        ) as actk
        where datediff(ss, accessTokenTs, now()) < accessTokenExpiresIn
    );
    
    return @result;

end
;