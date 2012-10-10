create or replace function vk.get(url long varchar)
returns long varchar
url '!url'
type 'http:get'
certificate 'file="c:\asafiles\vk.com.crt"'
;
