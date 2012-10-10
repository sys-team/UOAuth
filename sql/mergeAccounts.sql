create or replace procedure ua.mergeAccounts(@source integer, @target integer)
begin

    update ua.accountProviderData
       set account = @target
      from ua.accountProviderData apd
     where account = @source
       and not exists (select *
                         from ua.accountProviderData
                        where authProvider = apd.authProvider
                          and account = @target);
                          
    delete ua.accountProviderData
     where account = @source;
        
    update ua.accountClientData
       set account = @target    
      from ua.accountClientData acd
     where account = @source
       and not exists (select *
                         from ua.accountClientData
                        where client = acd.client
                          and account = @target);
                          
    delete ua.accountClientData
     where account = @source;
     
    update ua.accountRole 
       set account = @target    
      from ua.accountRole ar
     where account = @source
       and not exists (select *
                         from ua.accountRole 
                        where role = ar.role
                          and account = @target);
                          
    delete ua.accountRole
     where account = @source;
                               
    delete from ua.account
     where id = @source;

end
;