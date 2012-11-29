create or replace function google.processAuthCode
(
 url varchar(1024),
 code varchar(1024),
 client_id varchar(1024),
 client_secret varchar(1024),
 redirect_uri varchar(1024) default 'urn:ietf:wg:oauth:2.0:oob',
 grant_type varchar(1024) default 'authorization_code'
 )
returns long varchar
url '!url'
type 'HTTP:POST'
certificate 'file="c:\asafiles\system.unact.ru.crt"'
;