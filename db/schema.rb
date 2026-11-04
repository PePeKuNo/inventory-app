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

ActiveRecord::Schema[8.1].define(version: 2026_11_23_210000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accesses", force: :cascade do |t|
    t.bigint "inventory_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "user_id"], name: "index_accesses_on_inventory_id_and_user_id", unique: true
    t.index ["inventory_id"], name: "index_accesses_on_inventory_id"
    t.index ["user_id"], name: "index_accesses_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "inventory_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_comments_on_inventory_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "image_url"
    t.bigint "user_id", null: false
    t.bigint "category_id"
    t.boolean "is_public", default: false, null: false
    t.jsonb "custom_id_format", default: [], null: false
    t.integer "lock_version", default: 0, null: false
    t.boolean "custom_string1_state", default: false, null: false
    t.string "custom_string1_name"
    t.string "custom_string1_description"
    t.boolean "custom_string1_show_in_table", default: false, null: false
    t.integer "custom_string1_position", default: 0, null: false
    t.boolean "custom_string2_state", default: false, null: false
    t.string "custom_string2_name"
    t.string "custom_string2_description"
    t.boolean "custom_string2_show_in_table", default: false, null: false
    t.integer "custom_string2_position", default: 0, null: false
    t.boolean "custom_string3_state", default: false, null: false
    t.string "custom_string3_name"
    t.string "custom_string3_description"
    t.boolean "custom_string3_show_in_table", default: false, null: false
    t.integer "custom_string3_position", default: 0, null: false
    t.boolean "custom_text1_state", default: false, null: false
    t.string "custom_text1_name"
    t.string "custom_text1_description"
    t.boolean "custom_text1_show_in_table", default: false, null: false
    t.integer "custom_text1_position", default: 0, null: false
    t.boolean "custom_text2_state", default: false, null: false
    t.string "custom_text2_name"
    t.string "custom_text2_description"
    t.boolean "custom_text2_show_in_table", default: false, null: false
    t.integer "custom_text2_position", default: 0, null: false
    t.boolean "custom_text3_state", default: false, null: false
    t.string "custom_text3_name"
    t.string "custom_text3_description"
    t.boolean "custom_text3_show_in_table", default: false, null: false
    t.integer "custom_text3_position", default: 0, null: false
    t.boolean "custom_int1_state", default: false, null: false
    t.string "custom_int1_name"
    t.string "custom_int1_description"
    t.boolean "custom_int1_show_in_table", default: false, null: false
    t.integer "custom_int1_position", default: 0, null: false
    t.boolean "custom_int2_state", default: false, null: false
    t.string "custom_int2_name"
    t.string "custom_int2_description"
    t.boolean "custom_int2_show_in_table", default: false, null: false
    t.integer "custom_int2_position", default: 0, null: false
    t.boolean "custom_int3_state", default: false, null: false
    t.string "custom_int3_name"
    t.string "custom_int3_description"
    t.boolean "custom_int3_show_in_table", default: false, null: false
    t.integer "custom_int3_position", default: 0, null: false
    t.boolean "custom_link1_state", default: false, null: false
    t.string "custom_link1_name"
    t.string "custom_link1_description"
    t.boolean "custom_link1_show_in_table", default: false, null: false
    t.integer "custom_link1_position", default: 0, null: false
    t.boolean "custom_link2_state", default: false, null: false
    t.string "custom_link2_name"
    t.string "custom_link2_description"
    t.boolean "custom_link2_show_in_table", default: false, null: false
    t.integer "custom_link2_position", default: 0, null: false
    t.boolean "custom_link3_state", default: false, null: false
    t.string "custom_link3_name"
    t.string "custom_link3_description"
    t.boolean "custom_link3_show_in_table", default: false, null: false
    t.integer "custom_link3_position", default: 0, null: false
    t.boolean "custom_bool1_state", default: false, null: false
    t.string "custom_bool1_name"
    t.string "custom_bool1_description"
    t.boolean "custom_bool1_show_in_table", default: false, null: false
    t.integer "custom_bool1_position", default: 0, null: false
    t.boolean "custom_bool2_state", default: false, null: false
    t.string "custom_bool2_name"
    t.string "custom_bool2_description"
    t.boolean "custom_bool2_show_in_table", default: false, null: false
    t.integer "custom_bool2_position", default: 0, null: false
    t.boolean "custom_bool3_state", default: false, null: false
    t.string "custom_bool3_name"
    t.string "custom_bool3_description"
    t.boolean "custom_bool3_show_in_table", default: false, null: false
    t.integer "custom_bool3_position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_inventories_on_category_id"
    t.index ["user_id"], name: "index_inventories_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.bigint "inventory_id", null: false
    t.bigint "user_id"
    t.string "custom_id", null: false
    t.integer "sequence_number"
    t.integer "likes_count", default: 0, null: false
    t.integer "lock_version", default: 0, null: false
    t.string "custom_string1"
    t.string "custom_string2"
    t.string "custom_string3"
    t.text "custom_text1"
    t.text "custom_text2"
    t.text "custom_text3"
    t.decimal "custom_int1"
    t.decimal "custom_int2"
    t.decimal "custom_int3"
    t.string "custom_link1"
    t.string "custom_link2"
    t.string "custom_link3"
    t.boolean "custom_bool1"
    t.boolean "custom_bool2"
    t.boolean "custom_bool3"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "custom_id"], name: "index_items_on_inventory_id_and_custom_id", unique: true
    t.index ["inventory_id"], name: "index_items_on_inventory_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "likes", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id", "user_id"], name: "index_likes_on_item_id_and_user_id", unique: true
    t.index ["item_id"], name: "index_likes_on_item_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "inventory_id", null: false
    t.index ["inventory_id", "tag_id"], name: "index_taggings_on_inventory_id_and_tag_id", unique: true
    t.index ["inventory_id"], name: "index_taggings_on_inventory_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.boolean "admin", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accesses", "inventories"
  add_foreign_key "accesses", "users"
  add_foreign_key "comments", "inventories"
  add_foreign_key "comments", "users"
  add_foreign_key "inventories", "categories"
  add_foreign_key "inventories", "users"
  add_foreign_key "items", "inventories"
  add_foreign_key "items", "users", on_delete: :nullify
  add_foreign_key "likes", "items"
  add_foreign_key "likes", "users"
  add_foreign_key "taggings", "inventories"
  add_foreign_key "taggings", "tags"
end
