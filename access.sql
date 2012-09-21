create or replace function ua.access(@request long varchar)
returns xml
begin
    declare @response xml;

    declare @refreshToken varchar(1024);
    declare @accountId integer;    
    declare @accessToken varchar(1024);
    declare @expiresIn integer;
    
    set @refreshToken = isnull(http_variable('refresh-token'),'');
    
    set @accountId = (select id
                        from ua.account
                       where uRefreshToken = @refreshToken
                         and datediff(ss, uRefreshTokenTs, now()) < uRefreshTokenExpiresIn);
                         
    if @accountId is null then
        set @response = xmlelement('error','Not authorized');
        return @response;
    end if;
    
    select accessToken,
           expiresIn
      into @accessToken, @expiresIn
      from ua.newAccessToken(@accountId);
      
    set @response = xmlelement('access-token', xmlattributes(@expiresIn as "expire-after"), @accessToken)
                  + (select xmlelement('roles', xmlconcat(xmlagg(xmlelement('role',r.code)),xmlelement('role','authenticated')))
                       from ua.accountRole ar join ua.role r on ar.role = r.id
                      where ar.account = @accountId);
                        
    return @response;

end
;