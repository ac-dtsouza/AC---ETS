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

ActiveRecord::Schema.define(:version => 20120419124749) do

  create_table "admins", :force => true do |t|
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "banks", :force => true do |t|
    t.integer  "bankofhours_id"
    t.float    "bank_hours"
    t.datetime "last_reset"
    t.datetime "next_reset"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checks", :force => true do |t|
    t.string   "user_id"
    t.datetime "check_timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holidays", :force => true do |t|
    t.string   "day"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "justifications", :force => true do |t|
    t.string   "user_id"
    t.string   "date"
    t.string   "motive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "localized_positions", :force => true do |t|
    t.integer  "position_id"
    t.string   "position_desc_en"
    t.string   "position_desc_pt"
    t.integer  "position_workload"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "month_banks", :force => true do |t|
    t.integer  "bankofhours_id"
    t.float    "start_hours"
    t.float    "end_hours"
    t.datetime "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "parameters", :force => true do |t|
    t.string   "desc"
    t.float    "multiplier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "user_id"
    t.string   "user_name"
    t.integer  "position_id"
    t.integer  "bankofhours_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
