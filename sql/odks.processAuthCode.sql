create or replace function odks.processAuthCode(
    url long varchar,
    _address long varchar,
    code long varchar,
    redirect_uri long varchar,
    client_id long varchar,
    client_secret long varchar,
    grant_type long varchar default 'authorization_code'
)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert_name=*.sistemium.com'
;
