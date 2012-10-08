create global temporary table if not exists ua.log(
    url long varchar,
    clientIp varchar(64),
    request long varchar,
    response xml,

    cts datetime default current timestamp,
    
    xid uniqueidentifier,
    ts datetime default timestamp,
    primary key (xid)
)  not transactional share by all
;

create global temporary table if not exists ua.googleLog(
    url long varchar,
    request long varchar,
    response xml,

    cts datetime default current timestamp,
    
    xid uniqueidentifier,
    ts datetime default timestamp,
    primary key (xid)
)  not transactional share by all
;

create global temporary table if not exists ua.fbLog(
    url long varchar,
    response long varchar,

    cts datetime default current timestamp,
    
    xid uniqueidentifier,
    ts datetime default timestamp,
    primary key (xid)
)  not transactional share by all
;