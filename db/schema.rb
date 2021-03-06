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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150920162002) do

  create_table "books", force: :cascade do |t|
    t.string   "isbn"
    t.string   "asin"
    t.string   "title"
    t.string   "publisher"
    t.string   "author"
    t.text     "description"
    t.date     "publish_date"
    t.integer  "number_of_pages"
    t.integer  "price"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "image"
    t.datetime "evernote_post_at"
  end

  create_table "evernote_notebooks", force: :cascade do |t|
    t.string   "guid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
  end

end
