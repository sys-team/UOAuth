create or replace function ea.newAuthCode(
    @userId integer,
    @lifeTime integer default 4320,
    @requestXid GUID default null
)
returns long varchar
begin
    declare @code long varchar;
    
    set @code = ea.uuuid();
    
    update ea.account
       set authCode = @code,
           authCodeTs = now()
     where id = @userId;
     
    insert into ea.code with auto name
    select @userId as account,
           @requestXid as requestXid,
           @code as code,
           dateadd(mi, @lifeTime, now()) as ets;
           
    return @code;

end
;