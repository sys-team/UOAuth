create or replace function ea.newCode(
    @accountId integer,
    @requestXid GUID,
    @lifeTime integer default 3600,
    @roles long varchar default 'temporary access token'
)
returns long varchar
begin
    declare @code long varchar;   
    
    set @code = ea.uuuid();
    
    insert into ea.code with auto name
    select @accountId as account,
           @requestXid as requestXid,
           @code as code,
           @roles as roles,
           dateadd(mi, @lifeTime, now()) as ets;
           
    return @code;
end
;