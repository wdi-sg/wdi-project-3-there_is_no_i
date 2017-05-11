# Locavorus _Rex_

![Rex](http://i.imgur.com/VMuQpkL.png)

[**Locavorus**](https://locavorusrex.herokuapp.com/) is a (work-in-progress) web application for restaurants and other food businesses to manage their reservations, queue and orders. It aims to improve customer service by making various aspects of the service life cycle more efficient.

For example, queuing is automated, allowing customers to spend their time waiting for their table somewhere other than in a line. When it is their turn, the system will automatically notify them. In addition, customers can place their orders beforehand, so that their food can arrive at the table at the same time as them.

## The Project

### Objectives

:white_check_mark: Customers must be able to join the queue from a front-end interface (in this case, from a browser). They must be notified by SMS and must be able to submit their food orders online.

:white_check_mark: Customers must be able to make reservations and receive email confirmations. They should also be able to add advance orders.

:white_check_mark: Takeaway front end to process takeaway orders with email confirmations and integrated online payment system.

:white_check_mark: Reservation and queuing backend with automatic assignation of tables, attaching of orders and notifications.

:white_check_mark: Ordering backend to process takeaway, reservation, queuing and local orders with logic to prioritise orders for the kitchen.

:white_check_mark: Simple interface to find restaurants, view details, browse menus and contact the restaurants.

:white_check_mark: Simple interface to manage user accounts and an integrated restaurant dashboard to manage everything.

## Getting Started
### Prerequisites

This project is built with [Ruby on Rails](http://rubyonrails.org/) and [PostgreSQL](https://www.postgresql.org/). Follow the official instructions to download and install them.

### Installing

Fork, clone or download this repository to your desired directory. Install the necessary Gem files by entering the following code in your terminal in your directory:

```
bundle install
```

Run the following code to reset the database and populate it with seed data.

```
rails db:reset
```

The project will also require a .env file that contains all the secret variables used in the project. Change the file type of the included .env.sample file to .env and replace the values with your own. You have to start the application with the following command to utilise your secret variables:

```
foreman run rails s
```

### Deployment

#### Hosting
This project was deployed with Heroku, but you can choose your own server host. To use Heroku, go to https://www.heroku.com, create an account and follow the instructions to deploy your own project.

If you choose to go with Heroku, you will need to connect a Redis add-on in order to utilise ActionCable. Add your Redis url to _production_ in:

```
/config/cable.yml
```

### Built With
* Ruby on Rails
* PostgreSQL
* Embedded Ruby (ERB)
* JavaScript
* CSS
* jQuery
* Materialize

### Using the Application

#### Customer

![Customer Flow](http://i.imgur.com/0uOX0D6.jpg)

#### Restaurant

![Restaurant Flow]()

### Development

#### Entity Relationship Diagram (ERD)

![Initial ERD](http://i.imgur.com/2T5CDGE.jpg)

### Models
* User
* Order
* Restaurant
* Reservation
* Menu
* Table
* Invoice (previously 'Transaction')

## Notable Areas
### Reservation Table-finding Logic Flow
1. Find all tables in the restaurant.

2. Find all unavailable tables where the start time of the reservation is before the end time of that table OR the end time of the reservation is after the start time of that table.
![find unavailable table chart](http://i.imgur.com/DUb03pn.jpg)

3. Remove these unavailable tables from all tables in that restaurant.

4. From the remaining tables, filter out and accept only the tables with capacity greater than or equal to the number of diners.

5. Sort these tables in ascending order of capacity and select the first table in the array to reduce inefficiencies in seating e.g. assigning 2 people to an empty table meant for 6 people.

6. Use `Gmail` (connected to `Rails` framework) and ActiveJobs to send an automated email asynchronously to the user to confirm their reservation.

![email](http://i.imgur.com/ItgnGDt.png)

FOR FUTURE DEVELOPMENT: If no available tables are found, repeat the logic with wider time parameters and suggest other available time-slots to the user.

### Queuing Logic Flow
Tables will only be assigned when a customer is 'queuing' or when an existing diner is 'checked out'.

![user status](http://i.imgur.com/AJ66htW.jpg)
1. Use table-finding logic to find unoccupied tables and submit a reservation with `DateTime.now`.

2. If there are no available tables, add the user to the queue. User will receive a `Twilio` SMS with an estimated wait time.
![join queue](http://i.imgur.com/VNEfRAt.png)

3. When a diner checks out, run the table-finding logic again to find future reservations.

4. If there are no future reservations, assign a table to the first 'queuer' who can fit the table and send another `Twilio` SMS to inform the 'queuer' that they can make their way to the restaurant.
![confirmation](http://i.imgur.com/ljKzWwo.png)

5. Change status of the customer from _queuing_ to _dining_.

### Ordering

Orders can be created from four different entry points:

- takeaway
- reservation
- queuing
- in-restaurant

This means that different parameters are passed and checked to determine the correct type of order and to attach the necessary relevant information.

This also determines the order of food preparation by the kitchen. The orders are prioritised by time:

```
# if takeaway
order.invoice.takeaway_time

# if reservation
order.invoice.reservation.start_time

# if queuing
DateTime.now + est_wait_time

# if local order
order.created_at
```

#### Stripe
Online payment is managed through the easy-to-implement Stripe API.

![Stripe](http://i.imgur.com/x45HAc5.png)

### Website
**Dashboard Wireframe**
![Dashboard Wireframe](http://i.imgur.com/rW4d54q.png)

**Dashboard**
![Dashboard](http://i.imgur.com/vYzboPB.png)

**Nav Bar Dropdown Wireframe**
![Right Nav Wireframe](http://i.imgur.com/Wk8yk4z.png)

**Nav Bar Dropdown on /restaurants**
![Right Nav](http://i.imgur.com/NrsI8Ue.png)

## Future Development
### Wireframes for possible future features
**View Seated Diners**
![Seated Diners](http://i.imgur.com/36Qj59B.png)

**Kitchen View of Upcoming Tickets**
![Upcoming Tickets](http://i.imgur.com/IYXhqaQ.png)

**Kitchen View of Ready Tickets**
![Ready Tickets](http://i.imgur.com/mQE13Ee.png)

**Takeaway Dashboard**
![Takeaway Dash](http://i.imgur.com/PUgn0ws.png)

**Ordering Menu**
![Ordering Menu](http://i.imgur.com/nRXZ7EV.png)

**Order Chit**
![Order Chit](http://i.imgur.com/pRaPPjE.png)

**See All Orders**
![See all orders](http://i.imgur.com/CJjCfXi.png)

### Bugs :bug::gun:

#### date_select
'date_select' is used in the form_for inputs. This allows invalid dates (eg. 31 February) to be selected. Currently, validation checks in the controller are used, but a more robust method could be used for date inputs in forms.

#### ActionCable
Our ActionCable only uses one room, which means that while restaurants only see orders that belong to them, they are receiving all restaurants' orders, which can greatly affect performance. A per-restaurant system should be implemented to improve performance and security.

#### Ordering + Payment
For an unsolvable reason, the orders array is changed by methods applied to a copy of the array, which means that cancelling payment to add an item to the order will fail.

## Authors
- [Darrell Teo](https://github.com/darrelltzj)

- [Jonathan Louis Ng](https://github.com/noll-fyra)

- [Louisa Lee](https://github.com/imouto2005)

- Jasmine Lee (UX)

### Acknowledgments :sparkling_heart:
We would like to acknowledge **ourselves** for all the hard work that has gone into this project over the past 2 weeks and, more importantly, the people who have helped us along the way. **_-> Louisa_**

#### Coding assistance:
- Prima Aulia
- Kenneth Goh

#### Image credits:
- Logo: Max Alexander Ng
