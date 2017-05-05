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
  # User.create(
  user = User.new
  user.name = Faker::LordOfTheRings.character
  user.email = Faker::Internet.email
  user.password = 'password'
  # user.restaurant_id = rand(100) + 1
  user.save!
  # user.restaurants << @restaurants.sample
  # name: Faker::LordOfTheRings.character
  # email: Faker::Internet.email
  # password: 'password'
  # )
end

@restaurants = Restaurant.all
@users = User.all
100.times do
  @users.sample.restaurants << @restaurants.sample
end

500.times do
  MenuItem.create(
    name: Faker::Food.ingredient,
    price: ActionController::Base.helpers.number_with_precision(rand * 100, precision: 2),
    description: Faker::Food.ingredient,
    restaurant_id: rand(100) + 1
  )
end


index = 0
@restaurants.each do |restaurant|
  10.times do
    index += 1
    cap = rand(8)
    Table.create(
      restaurant_id: restaurant.id,
      name: index,
      # capacity_current: cap - rand(cap),
      capacity_current: 0,
      capacity_total: cap
    )
  end
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

100.times do
  Invoice.create(
    restaurant_id: rand(100) + 1,
    user_id: rand(100) + 1,
    user_name: Faker::Name.name,
    table_id: rand(10) + 1,
    reservation_id: rand(100) + 1
  )
end

100.times do
  Order.create(
    user_id: rand(100) + 1,
    menu_item_id: 5,
    invoice_id: rand(100) + 1,
    is_take_away: [true, false].sample
  )
end
