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

ActiveRecord::Schema.define(:version => 20131012212145) do

  create_table "craigs_sites", :force => true do |t|
    t.string   "city"
    t.string   "city_for_url"
    t.integer  "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "listings", :force => true do |t|
    t.integer  "year"
    t.integer  "model_id"
    t.integer  "price"
    t.boolean  "is_owner"
    t.integer  "zipcode"
    t.integer  "miles"
    t.integer  "phone",       :limit => 8
    t.integer  "scraping_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "make_id"
    t.datetime "post_date"
  end

  add_index "listings", ["make_id"], :name => "index_listings_on_make_id"
  add_index "listings", ["model_id"], :name => "index_listings_on_model_id"
  add_index "listings", ["price"], :name => "index_listings_on_price"
  add_index "listings", ["year"], :name => "index_listings_on_year"

  create_table "pics", :force => true do |t|
    t.string   "src"
    t.integer  "scraping_id"
    t.integer  "listing_id"
    t.integer  "thumb_for"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.boolean  "is_thumb"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  add_index "pics", ["listing_id"], :name => "index_pics_on_listing_id"
  add_index "pics", ["scraping_id"], :name => "index_pics_on_scraping_id"

  create_table "scrapings", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "url"
    t.datetime "post_date"
    t.integer  "guid",           :limit => 8
    t.string   "seller_type"
    t.string   "source"
    t.integer  "craigs_site_id"
    t.boolean  "parsed",                      :default => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.boolean  "dqed",                        :default => false
    t.integer  "price"
  end

  add_index "scrapings", ["guid"], :name => "index_scrapings_on_guid"

  create_table "spellings", :force => true do |t|
    t.string   "string"
    t.integer  "subdivision_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "spellings", ["subdivision_id"], :name => "index_spellings_on_subdivision_id"

  create_table "subdivisions", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "level"
  end

  add_index "subdivisions", ["level"], :name => "index_subdivisions_on_level"
  add_index "subdivisions", ["parent_id"], :name => "index_subdivisions_on_parent_id"

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
