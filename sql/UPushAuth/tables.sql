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

create table upa.client (

    name varchar(512) not null unique,
    code varchar(512) not null unique,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table upa.client is 'Приложение на устройстве'
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

create table upa.deviceClientRegistration(

    secret varchar(1024) not null,
    authCode varchar(1024) not null,

    not null foreign key(device) references upa.device on delete cascade,
    not null foreign key(client) references upa.client on delete cascade,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table upa.activationCode is 'Регистрация устройства для приложения'
;
