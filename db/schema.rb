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

ActiveRecord::Schema.define(version: 20140410152109) do

  create_table "clubs", force: true do |t|
    t.string   "url"
    t.string   "uid"
    t.text     "infos"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "matches", force: true do |t|
    t.datetime "match_date"
    t.string   "match_id"
    t.string   "home"
    t.string   "visitor"
    t.integer  "goals_home"
    t.integer  "goals_visitor"
    t.string   "result_image_path"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "temp_image_path"
    t.string   "orig_image_path"
  end

  create_table "teams", force: true do |t|
    t.string   "url"
    t.string   "name"
    t.integer  "club_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
