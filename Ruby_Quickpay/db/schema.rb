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

ActiveRecord::Schema[8.0].define(version: 2025_05_06_100043) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "group_request_participants", force: :cascade do |t|
    t.bigint "group_request_id", null: false
    t.bigint "participant_id", null: false
    t.decimal "amount", null: false
    t.boolean "paid", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_request_id"], name: "index_group_request_participants_on_group_request_id"
    t.index ["participant_id"], name: "index_group_request_participants_on_participant_id"
  end

  create_table "group_requests", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.float "total_amount"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_group_requests_on_creator_id"
  end

  create_table "password_reset_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "expires_at"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_password_reset_tokens_on_user_id"
  end

  create_table "payment_cards", force: :cascade do |t|
    t.string "card_number"
    t.string "cardholder_name"
    t.string "cvv"
    t.date "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "requests", force: :cascade do |t|
    t.integer "requester_id"
    t.integer "recipient_id"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "receiver_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_transactions_on_receiver_id"
    t.index ["sender_id"], name: "index_transactions_on_sender_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0
    t.decimal "balance", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_account_id"
    t.integer "friend_ids", default: [], array: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "group_request_participants", "group_requests"
  add_foreign_key "group_request_participants", "users", column: "participant_id"
  add_foreign_key "group_requests", "users", column: "creator_id"
  add_foreign_key "password_reset_tokens", "users"
  add_foreign_key "transactions", "users", column: "receiver_id"
  add_foreign_key "transactions", "users", column: "sender_id"
end
