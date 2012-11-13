create global temporary table if not exists upa.pushMessageLog(
    pushToken long varchar,
    msg long varchar,
    response long varchar,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;

create global temporary table upa.registerLog(

    pushToken long varchar,
    deviceType varchar(256),
    response long varchar,

    callerIP varchar(16) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;

create global temporary table upa.activateLog(

    deviceId varchar(256),
    activationCode varchar(1024),
    response long varchar,

    callerIP varchar(16) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;

create global temporary table upa.authLog(

    clientId varchar(256),
    redirectUrl long varchar,
    response long varchar,

    callerIP varchar(16) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;


create global temporary table upa.checkCredentialsLog(

    clientId varchar(256),
    clientSecret varchar(1024),
    accountCode varchar(1024),
    accountSecret varchar(1024),
    redirectUrl long varchar,
    response long varchar,

    callerIP varchar(16) default connection_property('ClientNodeAddress'),

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;
