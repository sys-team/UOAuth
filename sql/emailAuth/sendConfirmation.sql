create or replace procedure ea.sendConfirmation(
    @userId integer,
    @callback long varchar default null
)
begin

    declare @email long varchar;
    declare @code long varchar;
    declare @msg long varchar;
    
    select email,
           confirmationCode
      into @email, @code
      from dbo.udUser where id = @userId;
      
    set @msg = if @callback is not null then @callback + '?code=' + @code else @code endif;

    call email(@email,'EA Comnfimation Code',@msg);
    
    return;

end
;
