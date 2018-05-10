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

ActiveRecord::Schema.define(version: 20180510203809) do

  create_table "breeds", force: :cascade do |t|
    t.string "name"
  end

  create_table "pet_breeds", force: :cascade do |t|
    t.integer "pet_id"
    t.integer "breed_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string   "name"
    t.string   "animal_type"
    t.string   "age"
    t.string   "sex"
    t.string   "size"
    t.datetime "last_update"
    t.text     "description"
    t.string   "contact_phone"
    t.string   "email"
    t.integer  "shelter_id"
    t.string   "shelter_number"
    t.string   "api_pet_id"
  end

  create_table "shelters", force: :cascade do |t|
    t.string "shelter_number"
    t.string "name"
    t.string "street_address"
    t.string "street_address_2"
    t.string "city"
    t.string "state"
    t.string "phone"
    t.string "email"
  end

  create_table "user_pets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "pet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
  end

end
