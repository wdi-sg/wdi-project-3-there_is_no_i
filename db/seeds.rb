# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

100.times do
  Restaurant.create(
    name: Faker::Company.name,
    address1: Faker::Address.street_address,
    address_city: Faker::Address.city,
    address_country: Faker::Address.country,
    address_postal: Faker::Address.postcode,
    email: Faker::Internet.email,
    phone: rand(10_000_000..99_999_999),
    website: Faker::Internet.url,
    description: Faker::Company.buzzword,
    cuisine: Faker::Demographic.demonym,
    rating: rand(101),
    next_queue_number: 1
  )
end

100.times do
  User.create(
    name: Faker::LordOfTheRings.character,
    email: Faker::Internet.email,
    password: 'password',
    restaurant_id: rand(100) + 1
  )
end

500.times do
  MenuItem.create(
    name: Faker::Food.ingredient,
    price: ActionController::Base.helpers.number_with_precision(rand * 100, precision: 2),
    description: Faker::Food.ingredient,
    restaurant_id: rand(100) + 1
  )
end

# 500.times do
#   Table.create(
#     restaurant_id: rand(100) + 1,
#     name: rand(10).to_s,
#     capacity_current: 0,
#     capacity_total: rand(10) + 1
#   )
# end

@restaurants = Restaurant.all
@restaurants.each do |restaurant|
  Table.create([
                 {
                   restaurant_id: restaurant.id,
                   name: 1,
                   capacity_current: 2,
                   capacity_total: 2
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 2,
                   capacity_current: 0,
                   capacity_total: 2
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 3,
                   capacity_current: 0,
                   capacity_total: 2
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 4,
                   capacity_current: 4,
                   capacity_total: 4
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 5,
                   capacity_current: 3,
                   capacity_total: 4
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 6,
                   capacity_current: 0,
                   capacity_total: 4
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 7,
                   capacity_current: 6,
                   capacity_total: 6
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 8,
                   capacity_current: 0,
                   capacity_total: 6
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 9,
                   capacity_current: 7,
                   capacity_total: 8
                 },
                 {
                   restaurant_id: restaurant.id,
                   name: 10,
                   capacity_current: 0,
                   capacity_total: 8
                 }
               ])
end

500.times do
  x = Faker::Time.between(DateTime.now + 1, DateTime.now + rand(30) + 1)
  Reservation.create(
    user_id: rand(100) + 1,
    restaurant_id: rand(100) + 1,
    party_size: rand(10) + 1,
    phone: rand(10_000_000..99_999_999),
    name: Faker::StarWars.character,
    start_time: x,
    table_id: rand(10) + 1,
    end_time: x + 60 * 90
  )
end

# Restaurant.create([
#                     {
#                       name: 'Thai Restaurant',
#                       address1: 'Road 1',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 111_111,
#                       email: 'thai@restaurant.com',
#                       phone: '61111111', website: 'thai.com',
#                       description: 'thai restaurant',
#                       cuisine: 'thai',
#                       rating: 50
#                     },
#                     {
#                       name: 'French Restaurant',
#                       address1: 'Road 2',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 222_222,
#                       email: 'french@restaurant.com',
#                       phone: '62222222', website: 'french.com',
#                       description: 'french bistro',
#                       cuisine: 'french, parisien',
#                       rating: 70
#                     },
#                     {
#                       name: 'Italian Restaurant',
#                       address1: 'Road 3',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 333_333,
#                       email: 'italian@restaurant.com',
#                       phone: '63333333', website: 'italian.com',
#                       description: 'italian grandma\'s kitchen',
#                       cuisine: 'italian',
#                       rating: 80
#                     },
#                     {
#                       name: 'Chinese Restaurant',
#                       address1: 'Road 4',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 444_444,
#                       email: 'chinese@restaurant.com',
#                       phone: '64444444', website: 'chinese.com',
#                       description: 'chinese beautiful food',
#                       cuisine: 'chinese, cantonese',
#                       rating: 30
#                     },
#                     {
#                       name: 'Coffe Shop',
#                       address1: 'Road 5',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 555_555,
#                       email: 'coffee@shop.com',
#                       phone: '65555555', website: 'coffeeshop.com',
#                       description: 'coffee shop',
#                       cuisine: 'coffee, bakery',
#                       rating: 90
#                     },
#                     {
#                       name: 'Japanese Izakaya',
#                       address1: 'Road 6',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 666_666,
#                       email: 'japanese@restaurant.com',
#                       phone: '66666666', website: 'japanese.com',
#                       description: 'japanese izakaya',
#                       cuisine: 'japanese, izakaye',
#                       rating: 50
#                     },
#                     {
#                       name: 'Bak Chor Mee Stall',
#                       address1: 'Road 7',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 777_777,
#                       email: 'bakchormee@restaurant.com',
#                       phone: '67777777', website: 'bakchormee.com',
#                       description: 'bak chor mee',
#                       cuisine: 'singapore, bak chor mee, local',
#                       rating: 60
#                     },
#                     {
#                       name: 'Korean Restaurant',
#                       address1: 'Road 8',
#                       address_city: 'Singapore',
#                       address_country: 'Singapore',
#                       address_postal: 888_888,
#                       email: 'korean@restaurant.com',
#                       phone: '68888888', website: 'korean.com',
#                       description: 'korean restaurant',
#                       cuisine: 'korean',
#                       rating: 100
#                     }
#                   ])

# User.create([
#               {
#                 name: 'user1',
#                 email: 'user1@email.com',
#                 password: 'password',
#                 restaurant_id: 1
#               },
#               {
#                 name: 'user2',
#                 email: 'user2@email.com',
#                 password: 'password',
#                 restaurant_id: 3
#               },
#               {
#                 name: 'user3',
#                 email: 'user3@email.com',
#                 password: 'password',
#                 restaurant_id: 5
#               },
#               {
#                 name: 'user4',
#                 email: 'user1@email.com',
#                 password: 'password',
#                 restaurant_id: 7
#               },
#               {
#                 name: 'user5',
#                 email: 'user5@email.com',
#                 password: 'password'
#               },
#               {
#                 name: 'user6',
#                 email: 'user6@email.com',
#                 password: 'password'
#               },
#               {
#                 name: 'user7',
#                 email: 'user7@email.com',
#                 password: 'password'
#               },
#               {
#                 name: 'user8',
#                 email: 'user8@email.com',
#                 password: 'password'
#               }
#             ])

# MenuItem.create([
#                   {
#                     name: 'Pad Thai',
#                     price: 5.9,
#                     description: 'Fried noodles',
#                     restaurant_id: 1
#                   },
#                   {
#                     name: 'Pomelo Salad',
#                     price: 4.9,
#                     description: 'Pomelo salad',
#                     restaurant_id: 1
#                   },
#                   {
#                     name: 'Pineapple Rice',
#                     price: 5.9,
#                     description: 'Fried rice with pineapples',
#                     restaurant_id: 1
#                   },
#                   {
#                     name: 'Duck Confit',
#                     price: 16.8,
#                     description: 'Tender duck',
#                     restaurant_id: 2
#                   },
#                   {
#                     name: 'Potato Salad',
#                     price: 3.8,
#                     description: 'Potato salad',
#                     restaurant_id: 2
#                   },
#                   {
#                     name: 'Baguette',
#                     price: 4,
#                     description: 'Freshly baked',
#                     restaurant_id: 2
#                   },
#                   {
#                     name: 'Spaghetti Bolognese',
#                     price: 12.9,
#                     description: 'Yummy pasta',
#                     restaurant_id: 3
#                   },
#                   {
#                     name: 'Garlic Bread',
#                     price: 3.4,
#                     description: 'Pizza hut copycat',
#                     restaurant_id: 3
#                   },
#                   {
#                     name: 'Minestrone Soup',
#                     price: 8.9,
#                     description: 'Like nonna\'s',
#                     restaurant_id: 3
#                   },
#                   {
#                     name: 'Dumplings',
#                     price: 6,
#                     description: 'Dumplings',
#                     restaurant_id: 4
#                   },
#                   {
#                     name: 'Noodle Soup',
#                     price: 4.9,
#                     description: 'Noodle soup',
#                     restaurant_id: 4
#                   },
#                   {
#                     name: 'Fried Rice',
#                     price: 6,
#                     description: 'Fried rice',
#                     restaurant_id: 4
#                   }
#                 ])

# Reservation.create([
#                      {
#                        user_id: 1,
#                        restaurant_id: 1,
#                        party_size: 4,
#                        start_time: Date.new(2017, 5, 9)
#                      },
#                      {
#                        restaurant_id: 1,
#                        party_size: 3,
#                        start_time: Date.new(2017, 5, 12)
#                      },
#                      {
#                        restaurant_id: 1,
#                        party_size: 5,
#                        start_time: Date.new(2017, 5, 14)
#                      },
#                      {
#                        user_id: 2,
#                        restaurant_id: 2,
#                        party_size: 2,
#                        start_time: Date.new(2017, 5, 16)
#                      },
#                      {
#                        restaurant_id: 2,
#                        party_size: 3,
#                        start_time: Date.new(2017, 5, 9)
#                      },
#                      {
#                        restaurant_id: 2,
#                        party_size: 8,
#                        start_time: Date.new(2017, 5, 4)
#                      },
#                      {
#                        user_id: 3,
#                        restaurant_id: 3,
#                        party_size: 3,
#                        start_time: Date.new(2017, 5, 19)
#                      },
#                      {
#                        restaurant_id: 3,
#                        party_size: 4,
#                        start_time: Date.new(2017, 5, 26)
#                      },
#                      {
#                        restaurant_id: 3,
#                        party_size: 5,
#                        start_time: Date.new(2017, 5, 19)
#                      },
#                      {
#                        user_id: 4,
#                        restaurant_id: 4,
#                        party_size: 4,
#                        start_time: Date.new(2017, 5, 19)
#                      },
#                      {
#                        restaurant_id: 4,
#                        party_size: 4,
#                        start_time: Date.new(2017, 5, 19)
#                      },
#                      {
#                        restaurant_id: 4,
#                        party_size: 4,
#                        start_time: Date.new(2017, 5, 19)
#                      }
#                    ])

# Table.create([
#                {
#                  restaurant_id: 1,
#                  name: '1',
#                  capacity_total: 8
#                },
#                {
#                  restaurant_id: 1,
#                  name: '2',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 1,
#                  name: '3',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 1,
#                  name: '4',
#                  capacity_total: 2
#                },
#                {
#                  restaurant_id: 2,
#                  name: '1',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 2,
#                  name: '2',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 2,
#                  name: '3',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 2,
#                  name: '4',
#                  capacity_total: 2
#                },
#                {
#                  restaurant_id: 3,
#                  name: '1',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 3,
#                  name: '2',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 3,
#                  name: '3',
#                  capacity_total: 4
#                },
#                {
#                  restaurant_id: 3,
#                  name: '4',
#                  capacity_total: 6
#                },
#                {
#                  restaurant_id: 4,
#                  name: 'window',
#                  capacity_total: 5
#                },
#                {
#                  restaurant_id: 4,
#                  name: 'kitchen 2',
#                  capacity_total: 5
#                },
#                {
#                  restaurant_id: 4,
#                  name: 'kitchen 1',
#                  capacity_total: 5
#                },
#                {
#                  restaurant_id: 4,
#                  name: 'entrance',
#                  capacity_total: 3
#                }
#              ])
