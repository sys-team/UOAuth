grant connect to ua;
grant resource, dba to ua;
grant group to ua;

grant connect to google;
grant dba to google;

grant connect to mailru;
grant dba to mailru;

grant connect to odks;
grant dba to odks;

grant connect to vk;
grant dba to vk;

create table ua.client(

    name varchar(256) not null,
    code varchar(128) not null,
    secret varchar(128) not null,
    
    needsRefreshToken BOOL,
    
    redirectUrl long varchar,

    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
)
;
comment on table ua.client is 'Клиент (наша программа)'
;

create table ua.protocol(

    name varchar(256) not null,
    code varchar(128) not null unique,
    
    refreshTokenUrl long varchar,
    accessTokenUrl long varchar,

    id ID, xid GUID, ts TS, cts CTS,
    unique (xid), primary key (id)
)
;
comment on table ua.client is 'Протокол авторизации'
;


create table ua.authProvider(

    name varchar(256) not null,
    code varchar(128) not null unique,
    refreshTokenUrl long varchar,
    accessTokenUrl long varchar,
    
    clientId varchar(1024),
    clientSecret varchar(1024),
    clientPublicKey varchar(1024),
    
    not null foreign key(protocol) references ua.protocol,

    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
)
;
comment on table ua.authProvider is 'Внешний провайдер OAuth'
;

create table ua.clientAuthProviderRegData(

    authProvider integer,
    client integer,

    not null foreign key (authProvider) references ua.authProvider,
    not null foreign key (client) references ua.client,
    
    redirectUrl long varchar,

    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (authProvider, client),
    unique (xid),
    primary key (id)
)
;
comment on table ua.clientAuthProviderRegData is 'Дополнительные данные клиента для провайдера OAuth'
;

create table ua.account(

    name varchar(1024) not null,
    email varchar(128) not null unique,
    
    code varchar(256),
    
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
create text index xt_account_name_email_code on ua.account(name, email, code);

create table ua.accountProviderData(

    account integer,
    authProvider integer,

    not null foreign key (account) references ua.account on delete cascade,
    not null foreign key (authProvider) references ua.authProvider,   
    
    providerData xml,
    providerRefreshToken varchar(1024),
    providerUid varchar(256) not null,
    
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    unique (authProvider, providerUid),

    primary key (id)
 
)   
;
comment on table ua.account is 'Данные авторизации пользователя у внешнего провайдера'
;

create table ua.accountClientData (
    
    account integer,
    client integer,
    
    not null foreign key (account) references ua.account on delete cascade,
    not null foreign key (client) references ua.client,
    
    authCode varchar(256),
    authCodeTs datetime,
    authCodeExpiresIn integer,
    
    refreshToken varchar(256),
    refreshTokenTs datetime,
    refreshTokenExpiresIn integer,

    accessToken varchar(256),
    accessTokenTs datetime,
    accessTokenExpiresIn integer,
    
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
    
)
;
comment on table ua.accountClientData is 'Данные авторизации пользователя для нашего клиента'
;
create unique index xk_accountClientData_authCode on ua.accountClientData(authCode)
;
create unique index xk_accountClientData_refreshToken on ua.accountClientData(refreshToken)
;
create unique index xk_accountClientData_accessToken on ua.accountClientData(accessToken)
;

create table ua.role(
    
    name varchar(1024) not null,
    code varchar(128) not null unique,

    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
    
)
;
comment on table ua.role is 'Роль'
;


create table ua.accountRole(
    
    not null foreign key(account) references ua.account,
    not null foreign key(role) references ua.role,
    
    data STRING,
    
    id integer default autoincrement,
    cts datetime default current timestamp,
    ts datetime default timestamp,
    
    xid uniqueidentifier default newid(),
    
    unique (xid),
    primary key (id)
    
)
;
comment on table ua.role is 'Роль пользователя'
;
