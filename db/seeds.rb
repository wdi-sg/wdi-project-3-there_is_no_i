100.times do
  Restaurant.create(
    name: Faker::Company.name,
    address1: Faker::Address.street_address,
    address2: Faker::Address.street_address,
    address_city: Faker::Address.city,
    address_state: Faker::Address.state,
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
    phone: rand(10_000_000..99_999_999),
    password: 'password',
    restaurant_id: rand(100) + 1
  )
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
    restaurant_id: rand(100) + 1,
  )
end

@restaurants.each do |restaurant|
  index = 0
  10.times do
    index += 1
    Table.create(
      restaurant_id: restaurant.id,
      name: index,
      capacity_current: 0,
      capacity_total: rand(8)
    )
  end
  index = 0
end

500.times do
  x = Faker::Time.between(DateTime.now + 1, DateTime.now + rand(30) + 1)
  Reservation.create(
    user_id: rand(100) + 1,
    restaurant_id: rand(100) + 1,
    party_size: rand(10) + 1,
    phone: rand(10_000_000..99_999_999),
    email: Faker::Internet.email,
    name: Faker::StarWars.character,
    start_time: x,
    table_id: rand(10) + 1,
    end_time: x + 60 * 90,
    status: 'reservation'
  )
end

100.times do
  Invoice.create(
    restaurant_id: rand(100) + 1,
    user_id: rand(100) + 1,
    user_name: Faker::Name.name,
    table_id: rand(1000) + 1,
    reservation_id: rand(100) + 1
  )
end

500.times do
  Order.create(
    user_id: rand(100) + 1,
    menu_item_id: rand(500) + 1,
    invoice_id: rand(100) + 1,
    is_take_away: [true, false].sample
  )
end
