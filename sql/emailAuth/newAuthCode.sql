create or replace function ea.newAuthCode(@userId integer)
returns long varchar
begin
    declare @code long varchar;
    
    set @code = uuidtostr(newid());
    
    update dbo.udUser
       set authCode = @code
     where id = @userId;
     
    return @code;

end
;