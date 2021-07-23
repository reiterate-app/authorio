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

ActiveRecord::Schema.define(version: 2021_07_23_161041) do

  create_table "authorio_requests", force: :cascade do |t|
    t.string "code"
    t.string "redirect_uri"
    t.string "client"
    t.string "scope"
    t.integer "authorio_user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["authorio_user_id"], name: "index_authorio_requests_on_authorio_user_id"
  end

  create_table "authorio_tokens", force: :cascade do |t|
    t.string "client"
    t.string "scope"
    t.integer "authorio_user_id", null: false
    t.string "auth_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "expires_at"
    t.index ["auth_token"], name: "index_authorio_tokens_on_auth_token", unique: true
    t.index ["authorio_user_id"], name: "index_authorio_tokens_on_authorio_user_id"
  end

  create_table "authorio_users", force: :cascade do |t|
    t.string "profile_path"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["profile_path"], name: "index_authorio_users_on_profile_path", unique: true
  end

  add_foreign_key "authorio_requests", "authorio_users"
  add_foreign_key "authorio_tokens", "authorio_users"
end
