create or replace function ua.systemProxyGet(url long varchar)
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'file="c:\asafiles\system.unact.ru.crt"'
;