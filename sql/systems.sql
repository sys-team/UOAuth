create table if not exists ua.system (

    name STRING,
    code STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.func (

    name STRING,
    code STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.domain (

    name STRING,
    code STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


alter table ua.client add
    foreign key (system) references ua.system on delete cascade
;


create table if not exists ua.[functional] (

    not null foreign key (system) references ua.system on delete cascade,
    not null foreign key (func) references ua.func on delete cascade,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.[argument] (

    not null foreign key (functional) references ua.[functional] on delete cascade,
    not null foreign key (domain) references ua.domain on delete cascade,
    
    name STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.[value] (

    foreign key (client) references ua.system on delete cascade,
    foreign key (domain) references ua.domain on delete cascade,
    
    data STRING,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.[responsibility] (

    foreign key (role) references ua.[role] on delete cascade,
    foreign key (argument) references ua.[argument] on delete cascade,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


create table if not exists ua.[designation] (

    foreign key (accountRole) references ua.[accountRole] on delete cascade,
    foreign key (responsible) references ua.[responsibility] on delete cascade,
    foreign key ([for]) references ua.[value] on delete cascade,
    
    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)

);


