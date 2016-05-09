create or replace function vk.processAuthCode (
    url varchar(1024),
    code varchar(1024),
    client_id varchar(1024),
    client_secret varchar(1024),
    redirect_uri varchar(1024)
) returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert_name=*.sistemium.com'
;
