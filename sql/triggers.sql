-- account
create or replace trigger ua.tU_account after update on ua.account
referencing old as deleted new as inserted
for each row
begin
    declare @mergeTarget integer;
    
    -- merge
    if isnull(inserted.code,'') <> isnull(deleted.code,'') then
        set @mergeTarget = (select id
                              from ua.account
                             where code = inserted.code
                               and id <> inserted.id);
                               
        if @mergeTarget is not null then
            call ua.mergeAccounts(inserted.id, @mergeTarget);
        end if;
    
    end if;
end
;