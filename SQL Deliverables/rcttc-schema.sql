drop database if exists ramsey_county_ttc;
create database ramsey_county_ttc;

use ramsey_county_ttc;

create table customer (
	customer_id int primary key auto_increment,
    first_name nvarchar(50) not null,
    last_name nvarchar(50) not null,
    email nvarchar(50) not null,
    phone varchar(18) null,
    address varchar(75) null
);

create table theatre (
	theatre_id int primary key auto_increment,
    theatre_name varchar(50) not null,
    address varchar(75) not null,
    phone varchar(18) not null,
    email nvarchar(50) not null,
    capacity int null
);

create table production (
	show_id int primary key auto_increment,
    title varchar(75) not null
);

create table performance (
	performance_id int primary key auto_increment,
    show_id int not null,
    theatre_id int not null,
    night date not null,
    ticket_price decimal(6, 2) not null,
    constraint fk_show_id
		foreign key (show_id)
        references production(show_id),
	constraint fk_theatre_id
		foreign key (theatre_id)
        references theatre(theatre_id),
    constraint uq_show_theatre_night
		unique (show_id, theatre_id, night)
);

create table seat_performance (
	customer_id int not null,
    performance_id int not null,
    seat varchar(4) not null,
    constraint fk_customer_id
		foreign key (customer_id)
        references customer(customer_id),
	constraint fk_performance_id
		foreign key (performance_id)
        references performance(performance_id),
	constraint uq_performance_seat
		unique (performance_id, seat)
);