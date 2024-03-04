# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_03_02_104946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "category_name"
    t.string "full_name"
    t.float "points"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "clubs", force: :cascade do |t|
    t.string "club_name"
    t.string "territory"
    t.string "representative"
    t.string "email"
    t.string "phone"
    t.string "alternative_club_name"
    t.string "formatted_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "competitions", force: :cascade do |t|
    t.string "competition_name"
    t.date "date"
    t.string "location"
    t.string "country"
    t.string "distance_type"
    t.integer "wre_id"
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "ecn", default: false
  end

  create_table "entries", force: :cascade do |t|
    t.date "date"
    t.bigint "runner_id", null: false
    t.bigint "category_id", null: false
    t.bigint "result_id"
    t.string "status", default: "unconfirmed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["category_id"], name: "index_entries_on_category_id"
    t.index ["result_id"], name: "index_entries_on_result_id"
    t.index ["runner_id"], name: "index_entries_on_runner_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "group_name"
    t.bigint "competition_id", default: 0
    t.integer "rang"
    t.string "clasa"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "ecn_coeficient", default: 0.0
    t.index ["competition_id"], name: "index_groups_on_competition_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "place"
    t.bigint "runner_id", null: false
    t.integer "time", default: 0
    t.bigint "category_id", default: 10, null: false
    t.bigint "group_id", default: 0, null: false
    t.integer "wre_points"
    t.date "date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "ecn_points", default: 0.0
    t.index ["category_id"], name: "index_results_on_category_id"
    t.index ["group_id"], name: "index_results_on_group_id"
    t.index ["runner_id"], name: "index_results_on_runner_id"
  end

  create_table "runners", force: :cascade do |t|
    t.string "runner_name"
    t.string "surname"
    t.date "dob", default: "2024-01-23"
    t.bigint "club_id", default: 1
    t.string "gender"
    t.integer "wre_id"
    t.bigint "best_category_id", default: 10
    t.bigint "category_id", default: 10
    t.date "category_valid", default: "2100-01-01"
    t.integer "sprint_wre_rang"
    t.integer "forest_wre_rang"
    t.integer "sprint_wre_place"
    t.integer "forest_wre_place"
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "license", default: false
    t.index ["best_category_id"], name: "index_runners_on_best_category_id"
    t.index ["category_id"], name: "index_runners_on_category_id"
    t.index ["club_id"], name: "index_runners_on_club_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "admin", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "entries", "categories"
  add_foreign_key "entries", "results"
  add_foreign_key "entries", "runners"
  add_foreign_key "results", "categories"
  add_foreign_key "results", "groups"
  add_foreign_key "results", "runners"
end
