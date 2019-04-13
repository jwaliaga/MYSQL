use sakila;

-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select upper(concat(first_name, " ", last_name)) as "Actor Name"
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name
from actor
where last_name like "%LI%"
order by last_name, first_name asc;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country
from country
where country in ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor
add column description blob;

select * from actor limit 1;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
alter table actor
drop column description;

select * from actor limit 1;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name)
from actor
group by last_name
having count(last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
set sql_safe_updates = 0;
update actor
set first_name = "HARPO"
where first_name = "GROUCHO" and last_name = "WILLIAMS";
set sql_safe_updates = 1;

select * from actor
where first_name = "HARPO" and last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
set sql_safe_updates = 0;
update actor
set first_name = "GROUCHO"
where first_name = "HARPO" and last_name = "WILLIAMS";
set sql_safe_updates = 1;

select * from actor
where first_name = "GROUCHO" and last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address
from staff s join address a
on s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.first_name, s.last_name, sum(p.amount) as "Tot Sale Aug 2005"
from staff s join payment p
on s.staff_id = p.staff_id
where p.payment_date like '%2005-08%'
group by s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, count(fa.actor_id) as "# Actors Listed"
from film f inner join film_actor fa
on f.film_id = fa.film_id
group by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.title, count(i.inventory_id) as "Total Inventory"
from film f join inventory i
on f.film_id = i.film_id
group by f.title
having f.title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, sum(p.amount) as "Total Amount Paid"
from customer c join payment p
on c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where title like "Q%" or title like "K%"
and language_id in
(
	select language_id from language
    where name = "English"
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor
where actor_id in
(
 select actor_id
 from film_actor
 where film_id in
	(
		select film_id
        from film
        where title = "Alone Trip"
    )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

-- USING JOIN command

select c.first_name, c.last_name, c.email
from customer c join address a
on c.address_id = a.address_id
join city ci
on a.city_id = ci.city_id 
join country co
on ci.country_id = co.country_id
where co.country = "Canada";

-- USING SUB-QUERY

select first_name, last_name, email
from customer
where address_id in
(
	select address_id from address
    where city_id in
    (
		select city_id from city
        where country_id in
			(
				select country_id from country
                where country = "Canada"
            )
    )
);


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

-- USING SUB-QUERY

select title from film
where film_id in
	(
		select film_id from film_category
        where category_id in
        (
			select category_id from category
            where name = "family"
        )
    );

-- 7e. Display the most frequently rented movies in descending order.

-- USING SUB-QUERY AND JOIN COMMANDS

select f.title, sbq1.total as "Rent Frequency"
from film f join
(
	select i.film_id as film_id, count(r.inventory_id) as total
	from rental r join inventory i
	on i.inventory_id = r.inventory_id	
	group by i.film_id
   --  order by count(r.inventory_id) desc
) sbq1
on f.film_id = sbq1.film_id
order by sbq1.total desc, f.title desc
limit 10;
  
  -- USING JOIN COMMANDS
  
    select f.title, count(r.inventory_id) as "Rent Frequency" 
    from film f join inventory i  
    on f.film_id = i.film_id
    join rental r
    on i.inventory_id = r.inventory_id   
    group by f.title
    order by count(r.inventory_id) desc, f.title desc
    limit 10;
    
-- 7f. Write a query to display how much business, in dollars, each store brought in.

-- USING JOIN COMMANDS

select s.store_id, sum(p.amount) as "Total Sell"
from store s join staff st
on s.store_id = st.store_id
join payment p
on p.staff_id =st.staff_id
group by s.store_id;

-- USING SUB-QUERY AND JOIN COMMANDS

select s.store_id,
	(
		select sum(p.amount) 
        from staff st join payment p
        on p.staff_id =st.staff_id
        where s.store_id = st.store_id
    ) as "Total Sell"
from store s
group by s.store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

-- USING JOIN COMMAND

select s.store_id, ci.city, co.country
from store s join address a
on s.address_id = a.address_id
join city ci
on a.city_id = ci.city_id 
join country co
on ci.country_id = co.country_id;

/*
select s.store_id,
(
	select ci.city   
    from city ci
    where a.city_id = ci.city_id 
) sbq1
,
(
	select co.country
	from country co join city ci
    on ci.country_id = co.country_id	
) sbq2 
from store s join address a
on s.address_id = a.address_id;
*/

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

-- USING JOIN COMMAND

select c.name, sum(p.amount) as "Gross Revenue"
from category c join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view TopGrossRev as
select c.name, sum(p.amount) as "Gross Revenue"
from category c join film_category fc
on c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on r.inventory_id = i.inventory_id
join payment p
on r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from TopGrossRev;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view TopGrossRev;

