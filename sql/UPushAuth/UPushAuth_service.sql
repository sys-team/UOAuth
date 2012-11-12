drop service UPushAuth
;
create service UPushAuth
TYPE 'RAW' 
AUTHORIZATION OFF USER "upa"
url on
as call util.xml_for_http(upa.UPushAuth(:url));