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
    address_postal: 111111,
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
    address_postal: 222222,
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
    address_postal: 333333,
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
    address_postal: 444444,
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
    address_postal: 555555,
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
    address_postal: 666666,
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
    address_postal: 777777,
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
    address_postal: 888888,
    email: 'korean@restaurant.com',
    phone: '68888888', website: 'korean.com',
    description: 'korean restaurant',
    cuisine: 'korean',
    rating: 100
  }
  ])
