create or replace function ua.json2xml(@request long nvarchar)
returns long nvarchar
url 'https://api.sistemium.com/api/json2xml'
type 'HTTP:POST:text/json'
header 'Content-type:text/json'
certificate 'cert_name=*.sistemium.com'
;
