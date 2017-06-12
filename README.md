# Locavorus _Rex_
_**Simple reservations, queuing and ordering**_

![Rex](http://i.imgur.com/VMuQpkL.png)

[**Locavorus**](https://locavorusrex.herokuapp.com/) is a proof-of-concept web application for restaurants and other food businesses to manage their reservations, queue and orders. It aims to improve customer service by making various aspects of the service life cycle more efficient.

One aspect would be to allow customers to queue remotely. The system also automatically allocates the best available table to each customer and notifies them whenever the restaurant is ready. In addition, customers can place their orders beforehand, thus further reducing waiting time.

## The Project

### Objectives

:white_check_mark: Customers to be able to join the queue from a front-end interface (in this case, from a browser). They must be notified via SMS and must be able to submit their food orders online.

:white_check_mark: Customers to be able to submit their reservation and receive email confirmations.

:white_check_mark: Customers to be able to place takeaway orders with email confirmations.

:white_check_mark: System to handle reservation and queuing with automatic assignation, ordering and notification.

:white_check_mark: System to handle takeaway and local orders with logic to prioritise orders.

:white_check_mark: Simple interface to find restaurants and view details.

:white_check_mark: Simple interface to manage user accounts and business dashboard.

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

### The Application

#### Overview

![Right Nav](http://i.imgur.com/NrsI8Ue.png)

#### Customer Flow

<!-- ![Customer Flow](http://i.imgur.com/0uOX0D6.jpg) -->
<img src="http://i.imgur.com/0uOX0D6.jpg" height="500">

**Making a Reservation**

![Imgur](http://i.imgur.com/jVyNNTP.png)

<img src="http://i.imgur.com/ItgnGDt.png" height="500">
<br>
<br>

**Queuing**

<img src="http://i.imgur.com/VNEfRAt.png" height="500">

<img src="http://i.imgur.com/ljKzWwo.png" height="500">
<br>
<br>

**Takeaway Orders**

![Takeaway](http://i.imgur.com/PZEJ5xC.png)

![Stripe](http://i.imgur.com/DasuCUa.png)

![Takeaway Email](http://i.imgur.com/FQF7bCi.png)

#### Restaurant

**Dashboard**

![Dashboard](http://i.imgur.com/iCsmqur.png)

**Orders**

![Orders](http://i.imgur.com/NimOPLj.png)

**Invoices**

![Invoice](http://i.imgur.com/B1IQLuQ.png)

### Development

#### Entity Relationship Diagram (ERD)

<img src="http://i.imgur.com/2T5CDGE.jpg" height="800">

### Models
* User
* Order
* Restaurant
* Reservation
* Menu
* Table
* Invoice (previously 'Transaction')

### Notable Areas

Customer dining events are represented by the Reservation model. Below is the rough flow of how the status of the diner changes during each event.

<img src="http://i.imgur.com/AJ66htW.jpg" height="400">

#### Table-allocation Logic
The method below is called to determine a table for a potential diner.

**Method**
1. Find all tables in the restaurant.

2. Find all unavailable tables where the start time of the reservation is before the end time of that table OR the end time of the reservation is after the start time of that table.

3. Remove these unavailable tables from all tables in that restaurant.

4. From the remaining tables, filter out and accept only the tables with capacity greater than or equal to the number of diners.

5. Sort these tables in ascending order of capacity and select the first table in the array to reduce inefficiencies in seating. E.g. Assigning 3 people to an empty table meant for 4 people.

6. Select the table with the smallest possible capacity.

<img src="http://i.imgur.com/DUb03pn.jpg" height="400">

#### Queuing Logic
Tables will only be assigned / suggested whenever a diner starts 'queuing' or when an existing diner is 'checked out'.

1. Use table-finding logic to find unoccupied tables (tables with no 'Reservations' that are 'dining') and submit a reservation with `DateTime.now`.

2. If there are no available tables, add the user to the queue. User will receive a `Twilio` SMS with the number of people ahead of them and an estimated wait time if requested.

3. When a diner checks out, find the most suitable customer from the queue (one that can fit into the table with the priority going to the smallest queue number)and run the table-finding logic again to find future reservations.

4. If there are no future reservations, assign a table to the first 'queuer' who can fit the table and send another `Twilio` SMS to inform the 'queuer' that they can make their way to the restaurant.

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

### Wireframes
**Dashboard**
![Dashboard Wireframe](http://i.imgur.com/rW4d54q.png)

**Nav Bar Dropdown**
![Right Nav Wireframe](http://i.imgur.com/Wk8yk4z.png)

## Future Development
### Wireframes for possible future features
**View Seated Diners**
<img src="http://i.imgur.com/36Qj59B.png" height="500">
<!-- ![Seated Diners](http://i.imgur.com/36Qj59B.png) -->

**Kitchen View of Upcoming Tickets**
<img src="http://i.imgur.com/IYXhqaQ.png" height="500">
<!-- ![Upcoming Tickets](http://i.imgur.com/IYXhqaQ.png) -->

**Kitchen View of Ready Tickets**
<img src="http://i.imgur.com/mQE13Ee.png" height="500">
<!-- ![Ready Tickets](http://i.imgur.com/mQE13Ee.png) -->

**Takeaway Dashboard**
<img src="http://i.imgur.com/mQE13Ee.png" height="500">
<!-- ![Takeaway Dash](http://i.imgur.com/PUgn0ws.png) -->

**Ordering Menu**
<img src="http://i.imgur.com/mQE13Ee.png" height="500">
<!-- ![Ordering Menu](http://i.imgur.com/nRXZ7EV.png) -->

**Order Chit**
<img src="http://i.imgur.com/mQE13Ee.png" height="500">
<!-- ![Order Chit](http://i.imgur.com/pRaPPjE.png) -->

**See All Orders**
<img src="http://i.imgur.com/mQE13Ee.png" height="500">
<!-- ![See all orders](http://i.imgur.com/CJjCfXi.png) -->

<!-- **Kitchen View of Ready Tickets**
![Ready Tickets](app/assets/images/Kitchen_view.png) -->

**Suggestions for new Reservation Entries**

If no available tables are found, repeat the logic with wider time params and suggest other available time-slots to the user.

### Bugs :bug::gun:
The following bugs will also have to be fixed.

#### date_select
'date_select' is used in the form_for inputs. This allows invalid dates (eg. 31 February) to be selected. Currently, validation checks in the controller are used, but a more robust method could be used for date inputs in forms.

#### ActionCable
Our ActionCable only uses one room, which means that while we apply filters so restaurants only see orders that belong to them, they are receiving all restaurants' orders, which can greatly affect performance. A per-restaurant system should be implemented to improve performance and security.

#### Ordering + Payment
For an unsolvable reason, the orders array is changed by methods applied to a copy of the array, which means that cancelling payment to add an item to the order will fail as the array will now be empty. The previous values are stored, so if the customer pays immediately without adding any items, the order will proceed normally.

## Authors
- [Darrell Teo](https://github.com/darrelltzj)

- [Louisa Lee](https://github.com/imouto2005)

- [Jasmine Lee](https://www.behance.net/jasminely)

- [Jonathan Louis Ng](https://github.com/noll-fyra)

### Acknowledgments :sparkling_heart:

We acknowledge :smirk: ourselves :wink: for all the hard work that has gone into this project over the past 2 weeks, but more importantly, the people who have helped us along the way.

#### Coding assistance:
- Prima Aulia
- Kenneth Goh

#### Image credits:
- Logo: Max Alexander Ng
