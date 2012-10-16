create or replace function odks.sign(
    @access_token long varchar,
    @client_secret long varchar,
    @application_key long varchar,
    @format long varchar default 'XML'
)
returns long varchar
begin

    declare @result long varchar;
    
    set @result = hash('application_key=' +  @application_key
                    + 'format=' + @format
                    + hash(@access_token + @client_secret));    
    
    return @result;
    
end
;