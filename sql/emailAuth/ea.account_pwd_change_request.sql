create or replace procedure ea.account_pwd_change_request(
    @login long varchar,
    @callback long varchar default null,
    @smtpSender long varchar default null,
    @smtpServer long varchar default null)
begin
    declare @account integer;
    
    set @account = (select id
                      from ea.account
                     where (username = @login
                        or email = @login)
                       and confirmed = 1
                       and confirmationTs < dateadd(mi, -5, now()));
                       
    if @account is null then
        raiserror 55555 'InvalidLogin';
        return;
    end if;

    update ea.account
       set confirmationCode = ea.uuuid(),
           confirmationTs = now()
     where id = @account;
     
    call ea.sendConfirmation(@account, @callback, @smtpSender, @smtpServer); 

    select @login as [login];

end
;
