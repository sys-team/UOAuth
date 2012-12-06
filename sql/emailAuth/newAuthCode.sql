create or replace function ea.newAuthCode(@userId integer)
returns long varchar
begin
    declare @code long varchar;
    
    set @code = ea.uuuid();
    
    update ea.account
       set authCode = @code,
           authCodeTs = now()
     where id = @userId;
     
    return @code;

end
;