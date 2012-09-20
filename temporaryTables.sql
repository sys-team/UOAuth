create global temporary table if not exists ua.log(
    url long varchar,
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