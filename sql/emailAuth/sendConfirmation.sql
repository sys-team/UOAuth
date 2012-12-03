create or replace procedure ea.sendConfirmation(
    @userId integer,
    @callback long varchar default null,
    @smtpSender long varchar default null,
    @smtpServer long varchar default null
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
      from ea.user where id = @userId;
      

    set @msg = '<p><span>Code: </span><span>' + @code + '</span></p>'
             + if @callback is not null then '<p><span>' + @callback + @addChar + 'code=' + @code + '</span></p>' else '' endif;    

    if @smtpSender is null then
        call email(@email,'EA Comnfimation Code',@msg);
    else
        call email(@email,'EA Comnfimation Code',@msg, @smtpSender, @smtpServer);
    end if;
    
    return;

end
;
