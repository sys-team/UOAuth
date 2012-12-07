create or replace function ea.passwordCheck(@password long varchar)
returns integer
begin

    if @password not regexp '(?=^.{6,}$)((?=.*\d)|(?=.*\W))(?=.*[a-z])(?=.*[A-Z]).*$' then
        return 0
    else
        return 1
    end if
end
;
    
