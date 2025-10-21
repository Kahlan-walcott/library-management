create table customers (
    name varchar(50),
    phone_number varchar(30),
    email varchar(80),
    payment varchar(30),
    age int,
    primary key(email)
);

create table book (
    book_id int,
    title varchar(20),
    description varchar(100),
    price int,
    in_stock int,
    genre varchar(20),
    customers_email varchar(20),
    primary key(book_id),
    foreign key(customers_email) references customers(email)
);

create table librarian (
    librarian_id int,
    email varchar(20),
    inventory int,
    overdue_books varchar(20),
    available_unavailable varchar(50),
    available_unavailable_book varchar(30),
    primary key(librarian_id)
);
create table update_information (
    librarian_id int,
    book_id int,
    primary key (librarian_id, book_id)
);

create table transactions (
    transaction_id int,
    date_time varchar(50),
    amount int,
    customers_email varchar(20) unique,
    books_purchased int,
    foreign key(customers_email) references customers(email),
    primary key(transaction_id)
);

create table looks_at (
    librarian_id int,
    transaction_id int,
    primary key (librarian_id, transaction_id)
);

-- before a customer is added, make sure they are 18 or older.
create or replace trigger tg_age_checking
before
insert
on customers
for each row
declare
    valid_age int := 18;
begin
	if :new.age < valid_age then
    	raise_application_error(-20002,'You are to young to be purchasing a book.');
    else
        dbms_output.put_line('You have been put into the system.');
	end if;
end;
/

insert into customers values('teen', '61678945678', '2000@gmail.com', 'credit card', 15);
insert into customers values('ghost', '42882737', '2000@gmail.com', 'card', 21);
insert into customers values('been', '61678945371', '2001@gmail.com', 'cash', 18);
insert into customers values('john', '497293945', '190@gmail.com', 'card', 20);
insert into customers values('now', '1028471897', 'over@gmail.com', 'cash', 18);

insert into book values(321, 'thunder', 'chasing thunder', 201, 3, 'fanatic', '2000@gmail.com');
insert into book values(123, 'light', 'chasing storm', 200, 5, 'horror', '2001@gmail.com');
insert into book values(678, 'home', 'home is ...', 700, 2, 'feel good', '190@gmail.com');

insert into librarian values(456, 'librarian@gmail.com', 100, 'light', 'available', 'storm');
insert into librarian values(547, 'librarian2@gmail.com', 200, 'thunder', 'unavailable', 'light');

insert into transactions values(290, '10-2020', 700, '190@gmail.com', 1);
insert into transactions values(904, '10-1920', 200, '2000@gmail.com', 2);

-- Find the amount of genres and the genre that has more than or equal to 5 books in stock.
select count(genre), genre as genre_amount from book where in_stock >= 5 group by genre;

-- Find the description of the overdue books.
select description from book where title in (select overdue_books from librarian where overdue_books = title);

-- Find the unavailable books in the library.
select available_unavailable from librarian where available_unavailable = 'unavailable';

-- Find the price of each book the customer ordered in the year 2020.
select distinct price from book NATURAL JOIN customers where customers_email in (select customers_email from transactions where date_time like '%2020');

-- Find the name of the customer who made a transaction that was more than $100.
select name from customers c INNER JOIN transactions t ON c.email = t.customers_email where amount > 100;
