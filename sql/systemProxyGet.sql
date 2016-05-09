create or replace function ua.systemProxyGet(
    url long varchar
) returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'cert_name=*.sistemium.com'
;
