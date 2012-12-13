create or replace procedure ea.sendConfirmation(
    @userId integer,
    @callback long varchar default null,
    @smtpSender long varchar default null,
    @smtpServer long varchar default null,
    @subject long varchar default null
)
begin

    declare @email long varchar;
    declare @code long varchar;
    declare @msg long varchar;
    declare @addChar varchar(24);
    
    set @addChar = if locate(@callback,'?') <> 0 then '&' else '?' endif;
    
    select email,
           confirmationCode
      into @email, @code
      from ea.account where id = @userId;
      

    set @msg = '<p><span>Code: </span><span>' + @code + '</span></p>'
             + if @callback is not null then '<p><span>' + @callback + @addChar + 'code=' + @code + '</span></p>' else '' endif;    


    set @subject = isnull(@subject, @smtpSender + ' confirmation');
    
    if @smtpSender is null then
        call util.email(@email, @subject, @msg);
    else
        call util.email(@email, @subject, @msg, @smtpSender, @smtpServer);
    end if;

end
;
