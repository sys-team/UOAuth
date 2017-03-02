create or replace function ua.json2xml(@request long nvarchar)
returns long nvarchar
url 'http://api.sistemium.net/api/json2xml'
type 'HTTP:POST:text/json'
header 'Content-type:text/json';
