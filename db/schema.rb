# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170429095825) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "number"
    t.string   "type"
    t.integer  "expiry_month"
    t.integer  "expiry_year"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "menu_items", force: :cascade do |t|
    t.integer  "restaurant_id"
    t.string   "name"
    t.float    "price"
    t.text     "description"
    t.text     "ingredients"
    t.text     "tags"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "table_id"
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.integer  "item_id"
    t.text     "request_description"
    t.integer  "transaction_id"
    t.boolean  "is_take_away"
    t.datetime "time_end"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_name"
    t.string   "phone"
    t.string   "email"
    t.integer  "party_size"
    t.integer  "restaurant_id"
    t.date     "date"
    t.date     "time"
    t.boolean  "is_queuing"
    t.integer  "table_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "restaurants", force: :cascade do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "address_city"
    t.string   "address_state"
    t.string   "address_country"
    t.string   "address_postal"
    t.string   "email"
    t.string   "password"
    t.string   "phone"
    t.string   "website"
    t.string   "description"
    t.string   "cuisine"
    t.integer  "rating"
    t.string   "picture"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "restaurant_id"
    t.integer  "rating"
    t.text     "comments"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "tables", force: :cascade do |t|
    t.integer  "restaurant_id"
    t.string   "name"
    t.integer  "capacity_total"
    t.integer  "capacity_current"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "user_name"
    t.integer  "table_id"
    t.integer  "restaurant_id"
    t.datetime "time_end"
    t.datetime "takeaway_time"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "password"
    t.string   "password_digest"
    t.integer  "restaurant_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
