create or replace function ea.newConfirmationCode(
    @userId integer,
    @lifeTime integer default 30,
    @requestXid GUID default null
)
returns long varchar
begin
    declare @code long varchar;
    declare @roles xml;
    
    set @code = ea.uuuid();
    
    update ea.account
       set confirmationCode = @code,
           confirmationTs = now()
     where id = @userId;
     
    set @roles = xmlelement('data',
                            xmlelement('roles', xmlelement('role',
                            xmlattributes('ea.account' as "name", @userId as "id"))));
     
    insert into ea.code with auto name
    select @userId as account,
           @requestXid as requestXid,
           @code as code,
           @roles as roles,
           dateadd(mi, @lifeTime, now()) as ets;
     
    return @code;
end
;