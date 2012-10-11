create or replace function mailru.processAuthCode(
    url long varchar,
    client_id long varchar,
    client_secret long varchar,
    grant_type long varchar,
    code long varchar,
    redirect_uri long varchar
)
returns long varchar
url '!url'
type 'HTTP:POST:application/x-www-form-urlencoded'
certificate 'file="c:\asafiles\mail.ru.crt"'
;