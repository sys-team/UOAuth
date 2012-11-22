create table if not exists dbo.udUser (
	username varchar(50) not null unique,
	password varchar(200) not null,
	email varchar(512) not null unique,
	authCode varchar(1024) null,
	id integer not null default autoincrement,
	confirmationCode varchar(512) null,
	confirmed integer null default 0,
	confirmationTs datetime null,
	authCodeTs datetime null,
	primary key (id)
);
