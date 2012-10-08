create or replace function fb.get(url long varchar)
returns long varchar
url '!url'
type 'http:get'
certificate 'file="c:\asafiles\facebook.com.crt"'
;
