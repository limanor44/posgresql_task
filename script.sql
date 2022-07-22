CREATE DATABASE home_appliances
    WITH
    OWNER = limanor44
    ENCODING = 'UTF8'
    LC_COLLATE = 'Russian_Russia.1251'
    LC_CTYPE = 'Russian_Russia.1251'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

--categories

create table categories(
category_id serial primary key,
category_name varchar(100) not null UNIQUE
);
insert into categories (category_name) values ('HDD/SSD');
insert into categories (category_name) values ('Блок питания');
insert into categories (category_name) values ('Оперативная память');
insert into categories (category_name) values ('Видеокарта');

--manufacturer

create table manufacturer(
manufacturer_id serial primary key,
manufacturer_name varchar(100) not null UNIQUE
);
insert into manufacturer (manufacturer_name) values ('AMD');
insert into manufacturer (manufacturer_name) values ('Gigabyte');
insert into manufacturer (manufacturer_name) values ('MSI');
insert into manufacturer (manufacturer_name) values ('Intel');
insert into manufacturer (manufacturer_name) values ('HP');
insert into manufacturer (manufacturer_name) values ('SAMSUNG');
insert into manufacturer (manufacturer_name) values ('KINGSTON');

--stores

create table stores(
id serial primary key,
store_name varchar(255) not null
);
insert into stores (store_name) values ('Филиал №1');
insert into stores (store_name) values ('Филиал №2');
insert into stores (store_name) values ('Филиал №3');
insert into stores (store_name) values ('Филиал №4');
insert into stores (store_name) values ('Филиал №5');

--products 

create table products(
product_id serial primary key,
product_name varchar(255) UNIQUE,
manufacturer_id integer references manufacturer(manufacturer_id),
category_id integer references categories(category_id)
);

insert into products (product_name,manufacturer_id,category_id) values ('Radeon R5 128GB R5SL128G',1,1);
insert into products (product_name,manufacturer_id,category_id) values ('Radeon R5 256GB R5SL256G',1,1);
insert into products (product_name,manufacturer_id,category_id) values ('Slim S55 120GB',2,6);
insert into products (product_name,manufacturer_id,category_id) values ('Slim S55 246GB',2,6);
insert into products (product_name,manufacturer_id,category_id) values ('Product_1',3,5);
insert into products (product_name,manufacturer_id,category_id) values ('Product_2',3,5);
insert into products (product_name,manufacturer_id,category_id) values ('Product_3',4,3);
insert into products (product_name,manufacturer_id,category_id) values ('Product_4',4,3);
insert into products (product_name,manufacturer_id,category_id) values ('Product_5',1,1);
insert into products (product_name,manufacturer_id,category_id) values ('Product_6',2,3);
insert into products (product_name,manufacturer_id,category_id) values ('Product_7',3,5);
insert into products (product_name,manufacturer_id,category_id) values ('Product_8',2,6);
--deliveries

create table deliveries(
delivery_date date not null,
product_id integer references products(product_id),
store_id integer references stores(id),
product_count int check(product_count >= 1)
);

insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.2',1,1,10);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.2',1,2,15);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.3',2,1,18);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.3',2,2,11);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.5',3,1,10);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.6',3,2,15);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.7',4,1,12);
insert into deliveries (delivery_date,product_id,store_id,product_count) values ('2020.02.7',4,2,15);

--price
create table price(
product_id integer references products(product_id) not null unique,
	price integer not null
)
--
insert into price (product_id, price) values(1,1000)
insert into price (product_id, price) values(5,300);
insert into price (product_id, price) values(6,100);
insert into price (product_id, price) values(7,400);
insert into price (product_id, price) values(8,300);

--Операции с БД
select s.store_name, coalesce(sum(d.product_count),0)
from stores s 
left join deliveries d on s.id = d.store_id 
group by s.store_name 
having sum(d.product_count) > 0
--

select mf.manufacturer_namr, ca.category_name, s.store_name, sum(d.product_count) summa
from products pr 
left join manufacturer mf on pr.manufacturer_id = mf.manufacturer_id
left join categories ca on pr.category_id = ca.category_id
left join deliveries d on pr.product_id = d.product_id
left join stores s on s.id = d.store_id
group by s.store_name, mf.manufacturer_namr,ca.category_name
having sum(d.product_count) > 0
order by s.store_name

-- 

select d.delivery_date, pr.product_name, cg.category_name
from deliveries d
left join products pr on pr.product_id = d.product_id
left join categories cg on cg.category_id = pr.category_id
order by d.delivery_date

--
select cg.category_name, coalesce(sum(d.product_count),0)
from categories cg
left join products pr on pr.category_id = cg.category_id
left join deliveries d on d.product_id = pr.product_id
group by cg.category_name
--
create or replace function sum_products() returns bigint AS $$
begin
return sum(d.product_count) 
from products pr
left join deliveries d on d.product_id = pr.product_id;
end;
$$ language plpgsql
--
select * , max(pc.price) over()
from categories cg
left join products pr on pr.category_id = cg.category_id
left join price pc on pc.product_id=pr.product_id
where cg.category_id = 1
--
