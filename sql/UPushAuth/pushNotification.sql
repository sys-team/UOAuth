create or replace function upa.pushNotification(url long varchar, token long varchar, "message" long varchar)
returns long varchar
url '!url'
type 'http:get'
;
