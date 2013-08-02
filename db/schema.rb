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

ActiveRecord::Schema.define(:version => 20130802205224) do

  create_table "craigs_sites", :force => true do |t|
    t.string   "city"
    t.string   "city_for_url"
    t.integer  "zip"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

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
  end

end
