create or replace function mailru.sign(
    @secret_key long varchar,
    @app_id long varchar,
    @format long varchar,
    @method long varchar,
    @secure long varchar,
    @session_key long varchar

)
returns long varchar
begin
    declare @result long varchar;
    
    set @result = 'app_id=' + @app_id
                + 'format=' + @format
                + 'method=' + @method
                + 'secure=' + @secure
                + 'session_key=' + @session_key+
                + @secret_key;
                
    set @result = hash(@result);
       
    return @result;
    
end
;