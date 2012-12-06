create or replace function ea.uuuid()
returns long varchar
begin
    declare @result long varchar;
    
    set @result = hash(uuidtostr(newid()) + cast(rand() as varchar(24)));
    
    return @result;
end
;