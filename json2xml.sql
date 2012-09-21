create or replace function ua.json2xml(@request long varchar)
returns xml
url 'https://system.unact.ru/utils/json2xml.php'
type 'HTTP:POST:text/json'
header 'Content-type:text/json'
certificate 'file="c:\asafiles\system.unact.ru.crt"'
;
