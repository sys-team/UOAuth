create global temporary table if not exists upa.pushMessageLog(
    pushToken long varchar,
    msg long varchar,
    response long varchar,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
    
)  not transactional share by all
;