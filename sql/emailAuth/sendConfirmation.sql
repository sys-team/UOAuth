create or replace procedure ea.sendConfirmation(@userId integer)
begin

    declare @email long varchar;
    declare @code long varchar;
    
    select email,
           confirmationCode
      into @email, @code
      from dbo.udUser where id = @userId;

    call email(@email,'EA Comnfimation Code',@code);
    
    return;

end
;
