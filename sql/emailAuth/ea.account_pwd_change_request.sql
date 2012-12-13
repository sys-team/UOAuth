create or replace procedure ea.account_pwd_change_request(
    in @login long varchar,
    @callback long varchar default null,
    @smtpSender long varchar default null,
    @smtpServer long varchar default null,
    @subject long varchar default null)
begin
    declare @account integer;
    declare @confirmationTs datetime;
    
    select id,
           confirmationTs
      into @account, @confirmationTs
      from ea.account
     where (username = @login
        or email = @login)
       and confirmed = 1; 
     
    if @account is null then
        raiserror 55555 'InvalidLogin';
        return;
    end if;

    if @confirmationTs < dateadd(mi, -5, now()) then
        update ea.account
           set confirmationCode = ea.uuuid(),
               confirmationTs = now()
         where id = @account;
         
        call ea.sendConfirmation(@account, @callback, @smtpSender, @smtpServer, isnull(@subject, @smtpSender + ' confirmation'));
    end if;
    
    --select @login as [login];

end
;
grant execute on ea.account_pwd_change_request to public
;