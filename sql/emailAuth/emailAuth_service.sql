drop service emailAuth
;
create service emailAuth
TYPE 'RAW' 
AUTHORIZATION OFF USER "ea"
url on
as call util.xml_for_http(ea.emailAuth(:url));