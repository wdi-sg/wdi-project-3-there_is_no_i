# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

restaurants = Restaurant.create([
                                  {
                                    name: 'Thai Restaurant',
                                    address1: 'Road 1',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 111_111,
                                    email: 'thai@restaurant.com',
                                    phone: '61111111', website: 'thai.com',
                                    description: 'thai restaurant',
                                    cuisine: 'thai',
                                    rating: 50
                                  },
                                  {
                                    name: 'French Restaurant',
                                    address1: 'Road 2',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 222_222,
                                    email: 'french@restaurant.com',
                                    phone: '62222222', website: 'french.com',
                                    description: 'french bistro',
                                    cuisine: 'french, parisien',
                                    rating: 70
                                  },
                                  {
                                    name: 'Italian Restaurant',
                                    address1: 'Road 3',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 333_333,
                                    email: 'italian@restaurant.com',
                                    phone: '63333333', website: 'italian.com',
                                    description: 'italian grandma\'s kitchen',
                                    cuisine: 'italian',
                                    rating: 80
                                  },
                                  {
                                    name: 'Chinese Restaurant',
                                    address1: 'Road 4',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 444_444,
                                    email: 'chinese@restaurant.com',
                                    phone: '64444444', website: 'chinese.com',
                                    description: 'chinese beautiful food',
                                    cuisine: 'chinese, cantonese',
                                    rating: 30
                                  },
                                  {
                                    name: 'Coffe Shop',
                                    address1: 'Road 5',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 555_555,
                                    email: 'coffee@shop.com',
                                    phone: '65555555', website: 'coffeeshop.com',
                                    description: 'coffee shop',
                                    cuisine: 'coffee, bakery',
                                    rating: 90
                                  },
                                  {
                                    name: 'Japanese Izakaya',
                                    address1: 'Road 6',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 666_666,
                                    email: 'japanese@restaurant.com',
                                    phone: '66666666', website: 'japanese.com',
                                    description: 'japanese izakaya',
                                    cuisine: 'japanese, izakaye',
                                    rating: 50
                                  },
                                  {
                                    name: 'Bak Chor Mee Stall',
                                    address1: 'Road 7',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 777_777,
                                    email: 'bakchormee@restaurant.com',
                                    phone: '67777777', website: 'bakchormee.com',
                                    description: 'bak chor mee',
                                    cuisine: 'singapore, bak chor mee, local',
                                    rating: 60
                                  },
                                  {
                                    name: 'Korean Restaurant',
                                    address1: 'Road 8',
                                    address_city: 'Singapore',
                                    address_country: 'Singapore',
                                    address_postal: 888_888,
                                    email: 'korean@restaurant.com',
                                    phone: '68888888', website: 'korean.com',
                                    description: 'korean restaurant',
                                    cuisine: 'korean',
                                    rating: 100
                                  }
                                ])

users = User.create([
                      {
                        name: 'user1',
                        email: 'user1@email.com',
                        password: 'password',
                        restaurant_id: 1
                      },
                      {
                        name: 'user2',
                        email: 'user2@email.com',
                        password: 'password',
                        restaurant_id: 3
                      },
                      {
                        name: 'user3',
                        email: 'user3@email.com',
                        password: 'password',
                        restaurant_id: 5
                      },
                      {
                        name: 'user4',
                        email: 'user1@email.com',
                        password: 'password',
                        restaurant_id: 7
                      },
                      {
                        name: 'user5',
                        email: 'user5@email.com',
                        password: 'password'
                      },
                      {
                        name: 'user6',
                        email: 'user6@email.com',
                        password: 'password'
                      },
                      {
                        name: 'user7',
                        email: 'user7@email.com',
                        password: 'password'
                      },
                      {
                        name: 'user8',
                        email: 'user8@email.com',
                        password: 'password'
                      }
                    ])

menu_items = MenuItem.create([
                               {
                                 name: 'Pad Thai',
                                 price: 5.9,
                                 description: 'Fried noodles',
                                 restaurant_id: 1
                               },
                               {
                                 name: 'Pomelo Salad',
                                 price: 4.9,
                                 description: 'Pomelo salad',
                                 restaurant_id: 1
                               },
                               {
                                 name: 'Pineapple Rice',
                                 price: 5.9,
                                 description: 'Fried rice with pineapples',
                                 restaurant_id: 1
                               },
                               {
                                 name: 'Duck Confit',
                                 price: 16.8,
                                 description: 'Tender duck',
                                 restaurant_id: 2
                               },
                               {
                                 name: 'Potato Salad',
                                 price: 3.8,
                                 description: 'Potato salad',
                                 restaurant_id: 2
                               },
                               {
                                 name: 'Baguette',
                                 price: 4,
                                 description: 'Freshly baked',
                                 restaurant_id: 2
                               },
                               {
                                 name: 'Spaghetti Bolognese',
                                 price: 12.9,
                                 description: 'Yummy pasta',
                                 restaurant_id: 3
                               },
                               {
                                 name: 'Garlic Bread',
                                 price: 3.4,
                                 description: 'Pizza hut copycat',
                                 restaurant_id: 3
                               },
                               {
                                 name: 'Minestrone Soup',
                                 price: 8.9,
                                 description: 'Like nonna\'s',
                                 restaurant_id: 3
                               },
                               {
                                 name: 'Dumplings',
                                 price: 6,
                                 description: 'Dumplings',
                                 restaurant_id: 4
                               },
                               {
                                 name: 'Noodle Soup',
                                 price: 4.9,
                                 description: 'Noodle soup',
                                 restaurant_id: 4
                               },
                               {
                                 name: 'Fried Rice',
                                 price: 6,
                                 description: 'Fried rice',
                                 restaurant_id: 4
                               }
                             ])
