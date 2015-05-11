create or replace procedure ua.eternalAccount(
    @name string,
    @email string,
    @code string,
    @roles string,
    @clientCode string default 'rc_unact',
    @lifetime integer default 86400000
)
begin
    declare @account integer;
    declare @token string;

    declare local temporary table #roles (
        code string,
        data string,

        primary key(code)
    );

    if exists(
        select *
        from ua.account
        where name = @name
            or code = @code
            or email = @email
    ) then
        raiserror 55555 'Account already exist';
        return;
    end if;

    insert into #roles with auto name
    select code,
        data
    from openstring(value @roles)
        with(code string, data string)
        option(delimited by ':' row delimited by '|') as t;

    insert into ua.account with auto name
    select @name as name,
        @code as code,
        @email as email;

    set @account = @@identity;

    insert into ua.role with auto name
    select code as name,
        code
    from #roles
    where not exists(
        select *
        from ua.role
        where code = #roles.code
    );

    insert into ua.accountRole with auto name
    select @account as account,
        r.id as role,
        rr.data
    from ua.role r join #roles rr on r.code = rr.code;

    set @token = uuidtostr(util.UDGuid());

    insert into ua.accountClientData with auto name
    select id as client,
        @account as account,
        @token as accessToken,
        now() as accessTokenTs,
        @lifetime as accessTokenExpiresIn
    from ua.client c
    where c.code = @clientCode;


    select @token as accessToken;

end
;
