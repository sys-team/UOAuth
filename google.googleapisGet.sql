create or replace function google.googleapisGet(url long varchar)
returns long varchar
url '!url'
type 'http:get'
certificate 'file="c:\asafiles\googleapis.com.crt"'
;
