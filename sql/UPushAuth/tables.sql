create table upa.device(

    pushToken varchar(1024),
    deviceType varchar(128) not null,
    registered BOOL,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table upa.device is 'Устройство'
;

create table upa.activationCode(

    code varchar(1024) not null unique,
    
    not null foreign key(device) references upa.device on delete cascade,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table upa.activationCode is 'Код активации устройства'
;