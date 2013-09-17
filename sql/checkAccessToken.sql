create or replace function ua.checkAccessToken(@accessToken varchar(1024))
returns integer
begin

    declare @result integer;
    
    set @result = isnull(
        (select account
            from ua.accountClientData
            where accessToken = @accessToken
                and datediff(ss, accessTokenTs, now()) < accessTokenExpiresIn
        ),
        (select ad.account
            from ua.accountClientData ad
                join ua.accountClientDataAccessToken adt
                on ad.id = adt.accountClientData
            where adt.accessToken = @accessToken
                and datediff(ss, adt.accessTokenTs, now()) < adt.accessTokenExpiresIn
        )
    );
    
    return @result;
    
end;