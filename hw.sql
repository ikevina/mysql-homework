USE sakila;


#1a
select first_name, last_name from actor;


#1b
select upper(concat(first_name, ' ', last_name)) as actor_name from actor;


#2a
select actor_id, first_name, last_name from actor
	where first_name = "Joe";

#2b
select actor_id, first_name, last_name from actor where last_name like "%GEN%"; 

#2c
select last_name, first_name from actor where last_name like "%LI%";

#2d
select country_id, country from country
	where country IN ("Afghanistan", "Bangladesh", "China");


#3a
alter table actor add column middle_name varchar(45) not null after first_name;

#3b
alter TABLE actor modify column middle_name blob;

#3c
alter table actor drop COLUMN middle_name;


#4a
select last_name, count(last_name) as same_name_count from actor
	group by last_name;

#4b
select last_name, count(last_name) as more_than_2 from actor
	group by last_name having more_than_2 >= 2;

#4c
#select  Actor_name, first_name, last_name from actor where Actor_name = "groucho williams"; #check the result
update actor set first_name = "HARPO" WHERE first_name = "GROUCHO";
#update actor set Actor_name = "HARPO WILLIAMS" where Actor_name = "groucho williams";

#4d
update actor set first_name = if (first_name = "HARPO", "GROUCHO", if(first_name = "GROUCHO", "MUCHO GROUCHO",
	if(first_name = "MUCHO GROUCHO", "HARPO", first_name)));

#4d v.2
update actor set first_name = case when first_name = "HARPO" then "GROUCHO" when first_name = "GROUCHO" then "MUCHO GROUCHO"
	when first_name = "MUCHO GROUCHO" then "HARPO" else first_name end;


#5a
CREATE TABLE `address`(
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;


#6a
select first_name, last_name, address.address from staff
	join address on address.address_id = staff.address_id;

#6a v.2
select first_name, last_name, (select address from address
	where address.address_id = staff.address_id) as address
	from staff;

#6b version with joins
select first_name, last_name, sum(payment.amount) as total_payment from staff
	join payment on staff.staff_id = payment.staff_id where payment_date > '2005-08-01 00:00:00' and payment_date < '2005-09-01 00:00:00'
	group by staff.staff_id;

#6b v.2 version with subqueries
select first_name, last_name, (select sum(amount) from payment
	where staff.staff_id = payment.staff_id and payment_date > '2005-08-01 00:00:00' and payment_date < '2005-09-01 00:00:00') as total_payment
	from staff;

#6c version with joins
select title, count(actor_id) as actors_number from film
	join film_actor on film.film_id = film_actor.film_id group by film.film_id;

#6c v.2 version with subqueries
select title, (select count(actor_id) from film_actor where film.film_id = film_actor.film_id) as actors_number from film;

#6d
select count(*) as number_of_copies from inventory
	where film_id in (
		select film_id from film
			where title = "Hunchback Impossible" 
        );

#6e version with joins
select first_name, last_name, sum(amount) as total_payment from payment 
	join customer on payment.customer_id = customer.customer_id
    GROUP BY payment.customer_id ORDER BY last_name;

#6e v.2 version with subqueries
select first_name, last_name,
	(select sum(amount) from payment
		where payment.customer_id = customer.customer_id) as total_payment
from customer ORDER BY last_name;


#7a
select title from film
	where title like "K%" OR title like "Q%" and language_id IN (
		select language_id from language
			where name = "English"
    );

#7b
select first_name, last_name FROM actor
	where actor_id in (
		select actor_id from film_actor
			where film_id in (
				select film_id from film
					where title = "Alone Trip"
	));

#7c version with joins
select email from customer
	inner join address on address.address_id = customer.address_id
    inner join city on city.city_id = address.city_id
    inner join country on country.country_id = city.country_id
		where country = "Canada";

#7c v.2 version with subqueries
select email from customer
	where address_id in (
		select address_id from address
			where city_id in (
				select city_id from city
					where country_id in (
						select country_id from country
							where country = "Canada"
		)));

#7d version with joins
select title from film
	inner join film_category on film.film_id =  film_category.film_id
    inner join category on category.category_id = film_category.category_id
    where category.name = "Family";

#7d v.2 version with subqueries
SELECT title from film
	where film_id in (
		select film_id from film_category
			where category_id in (
				select category_id from category
					where name = "Family"
		));

#7e
select title, (
	select count(*) from rental
		where inventory_id in (
			select inventory_id from inventory
				where inventory.film_id = film.film_id
			)) as rental_number
	from film order by rental_number desc;
    
#7f


#7g
select store_id, (
	SELECT city from city
		where city_id in (
			select city_id from address
				where address.address_id = store.address_id
		)) as city_name, (
	select country from country
			where country_id in (
				select country_id from city
					where city = city_name
		)) as country_name
	from store;

#7h
select name as genre_name, (
	select sum(amount) from payment
		where rental_id in (
			SELECT rental_id from rental
				where inventory_id in (
					select inventory_id from inventory
						where film_id in (
							select film_id from film_category
								where film_category.category_id = category.category_id
		)))) as genre_gross
	from category ORDER BY genre_gross DESC limit 5;


#8a
create view top_5_genres as
select category.name as genre_name, sum(payment.amount) as genre_gross from payment
		inner join rental on rental.rental_id = payment.rental_id
        inner join inventory on inventory.inventory_id = rental.inventory_id
        INNER join film_category on film_category.film_id = inventory.film_id
        inner join category on category.category_id = film_category.category_id
            group by genre_name order by genre_gross desc limit 5;