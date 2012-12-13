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
                       and confirmationTs > isnull(lastLogin, today()-1));
                       
    if @account is null then
        raiserror 55555 'InvalidCode';
        return;
    end if;
    
    if ea.passwordCheck(@password) = 0 then         
        raiserror 55555 'InvalidPass';
        return;
    end if;
    
    update ea.account
       set password = hash(@password,'SHA256'),
           confirmationCode = null
     where id = @account;
     
     --select @account as [account-id];

end
;
grant execute on ea.account_pwd_change to public
;