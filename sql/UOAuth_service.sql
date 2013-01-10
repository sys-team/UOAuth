sa_make_object 'service', 'UOAuth'
;
alter service UOAuth
type 'raw' 
authorization off user "dba"
url on
as call util.xml_for_http(ua.UOAuth(:url));