create or replace function upa.parseRedirectUrl(@redirectUrl long varchar)
returns long varchar
begin

    declare @result long varchar;

    set @result = isnull(substring(@redirectUrl, locate(@redirectUrl,'upush://') + 8),'');
    
    return @result;

end
;