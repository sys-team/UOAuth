create or replace procedure ea.account_pwd_change(
    @code long varchar,
    @password long varchar
)
begin
    declare @account integer;

    set @account = (select id
                      from ea.account
                     where confirmationCode = @code
                       and confirmationTs > dateadd(mi, -5, now())
                       and confirmationTs > lastLogin);
                       
    if @account is null then
        raiserror 55555 'InvalidCode';
        return;
    end if;
    
    if ea.passwordCheck(@password) = 0 then         
        raiserror 55555 'InvalidPass';
        return;
    end if;
    
    update ea.account
       set password = hash(@password,'SHA256')
     where id = @account;

    select @account as [account-id];
end
;