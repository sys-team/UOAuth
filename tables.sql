grant connect to ua;
grant resource, dba to ua;
grant group to ua;


create table ua.clientSecret(

    clientId varchar(1024) not null unique,
    clientSecret varchar(1024) not null,
    
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
)
;
comment on table ua.clientSecret is 'Ид клиента и секрет клиента'
;

create table ua.authProvider(

    code varchar(128) not null unique,
    refreshTokenUrl long varchar,
    accessTokenUrl long varchar,
        
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
)
;
comment on table ua.authProvider is 'Провайдер OAuth'
;

create table ua.account(

    name varchar(1024) not null unique,
    email varchar(128) not null unique,
    
    providerData xml,
    providerRefreshToken varchar(1024),
    
    uRefreshToken varchar(1024),
    uRefrechTokenTs datetime,
    uRefrechTokenExpiresIn integer,
    
    foreign key(authProvider) references ua.authProvider,
        
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
    
)
;
comment on table ua.account is 'Пользователь'
;
