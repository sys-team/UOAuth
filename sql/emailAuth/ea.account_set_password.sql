create or replace procedure ea.account_set_password (
    @id integer,
    @old_password long varchar,
    @new_password long varchar
)
begin


    if exists(select *
                from ea.account
               where id = @id
                 and password = hash(@old_password,'SHA256')) then
         
        if ea.passwordCheck(@new_password) = 1 then         
            update ea.account
               set password = hash(@new_password,'SHA256')
             where id = @id;

        else
            raiserror 55555 'InvalidPass';
            return;
        end if;
    else
        raiserror 55555 'InvalidLogPass';
        return;           
    end if;

end
;