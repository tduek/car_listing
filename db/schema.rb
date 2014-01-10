# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140102002527) do

  create_table "listings", :force => true do |t|
    t.integer  "year"
    t.integer  "make_id"
    t.integer  "model_id"
    t.integer  "price"
    t.string   "title"
    t.text     "description"
    t.boolean  "is_owner"
    t.integer  "zipcode"
    t.integer  "miles"
    t.integer  "phone",       :limit => 8
    t.datetime "post_date"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "listings", ["is_owner"], :name => "index_listings_on_is_owner"
  add_index "listings", ["make_id"], :name => "index_listings_on_make_id"
  add_index "listings", ["model_id"], :name => "index_listings_on_model_id"
  add_index "listings", ["price"], :name => "index_listings_on_price"
  add_index "listings", ["year"], :name => "index_listings_on_year"
  add_index "listings", ["zipcode"], :name => "index_listings_on_zipcode"

  create_table "pics", :force => true do |t|
    t.integer  "listing_id"
    t.boolean  "is_thumb"
    t.integer  "thumb_for"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "pics", ["is_thumb"], :name => "index_pics_on_is_thumb"
  add_index "pics", ["listing_id"], :name => "index_pics_on_listing_id"

  create_table "subdivisions", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "level"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subdivisions", ["level"], :name => "index_subdivisions_on_level"
  add_index "subdivisions", ["parent_id"], :name => "index_subdivisions_on_parent_id"

  create_table "user_sessions", :force => true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.string   "phone"
    t.string   "address_line_1"
    t.string   "address_line_2"
    t.string   "city"
    t.integer  "zip"
    t.string   "password_digest"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.string   "state"
    t.boolean  "is_activated"
    t.string   "activation_token"
    t.datetime "activation_email_sent_at"
    t.string   "reset_password_token"
  end

  create_table "zips", :force => true do |t|
    t.integer  "code"
    t.string   "city"
    t.string   "state"
    t.string   "st"
    t.decimal  "lat"
    t.decimal  "long"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "zips", ["code"], :name => "index_zips_on_code"
  add_index "zips", ["lat"], :name => "index_zips_on_lat"
  add_index "zips", ["long"], :name => "index_zips_on_long"

end
