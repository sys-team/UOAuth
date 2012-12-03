create global temporary table ea.log(
    
    httpBody long varchar,
    service varchar(255),
    "login" varchar(1024),
    password varchar(1024),
    email varchar(1024),
    code varchar(1024),
    
    response xml,

    callerIP varchar(255) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;