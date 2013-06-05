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

ActiveRecord::Schema.define(:version => 20130531143625) do

  create_table "admins", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admins", ["authentication_token"], :name => "index_admins_on_authentication_token", :unique => true
  add_index "admins", ["confirmation_token"], :name => "index_admins_on_confirmation_token", :unique => true
  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true
  add_index "admins", ["unlock_token"], :name => "index_admins_on_unlock_token", :unique => true

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "category_type"
    t.string   "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "pixi_type"
  end

  create_table "contacts", :force => true do |t|
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "home_phone"
    t.string   "work_phone"
    t.string   "mobile_phone"
    t.string   "website"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "country"
  end

  add_index "contacts", ["contactable_id"], :name => "index_contacts_on_contactable_id"

  create_table "interests", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "interests", ["name"], :name => "index_interests_on_name"

  create_table "invoices", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.integer  "quantity"
    t.float    "price"
    t.float    "amount"
    t.text     "comment"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "status"
    t.float    "sales_tax"
    t.datetime "inv_date"
    t.float    "subtotal"
    t.float    "tax_total"
    t.integer  "transaction_id"
  end

  add_index "invoices", ["pixi_id", "buyer_id", "seller_id"], :name => "index_invoices_on_pixi_id_and_buyer_id_and_seller_id"
  add_index "invoices", ["status"], :name => "index_invoices_on_status"
  add_index "invoices", ["transaction_id"], :name => "index_invoices_on_transaction_id"

  create_table "listing_categories", :force => true do |t|
    t.integer  "category_id"
    t.integer  "listing_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "listing_categories", ["category_id", "listing_id"], :name => "index_listing_categories_on_category_id_and_listing_id"

  create_table "listings", :force => true do |t|
    t.string   "title"
    t.integer  "category_id"
    t.text     "description"
    t.string   "status"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.float    "price"
    t.string   "show_alias_flg"
    t.string   "show_phone_flg"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "alias_name"
    t.datetime "start_date"
    t.integer  "site_id"
    t.datetime "end_date"
    t.integer  "transaction_id"
    t.string   "pixi_id"
    t.string   "edited_by"
    t.datetime "edited_dt"
    t.string   "post_ip"
  end

  add_index "listings", ["end_date", "start_date"], :name => "index_listings_on_end_date_and_start_date"
  add_index "listings", ["pixi_id"], :name => "index_listings_on_pixi_id", :unique => true
  add_index "listings", ["site_id", "seller_id", "start_date"], :name => "index_listings_on_org_id_and_seller_id_and_start_date"
  add_index "listings", ["status"], :name => "index_listings_on_status"
  add_index "listings", ["transaction_id"], :name => "index_listings_on_transaction_id"

  create_table "pictures", :force => true do |t|
    t.string   "delete_flg"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  create_table "pixi_points", :force => true do |t|
    t.integer  "value"
    t.string   "action_name"
    t.string   "category_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "code"
  end

  add_index "pixi_points", ["code"], :name => "index_pixi_points_on_code"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "listing_id"
    t.text     "content"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "pixi_id"
    t.integer  "recipient_id"
  end

  add_index "posts", ["pixi_id"], :name => "index_posts_on_pixi_id"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id_and_created_at", :unique => true

  create_table "promo_codes", :force => true do |t|
    t.string   "code"
    t.string   "promo_name"
    t.string   "description"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "status"
    t.integer  "max_redemptions"
    t.integer  "amountOff"
    t.integer  "percentOff"
    t.string   "currency"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "promo_type"
    t.integer  "site_id"
  end

  add_index "promo_codes", ["code", "status"], :name => "index_promo_codes_on_code_and_status"
  add_index "promo_codes", ["end_date", "start_date"], :name => "index_promo_codes_on_end_date_and_start_date"
  add_index "promo_codes", ["site_id"], :name => "index_promo_codes_on_site_id"

  create_table "read_marks", :force => true do |t|
    t.integer  "readable_id"
    t.integer  "user_id",                     :null => false
    t.string   "readable_type", :limit => 20, :null => false
    t.datetime "timestamp"
  end

  add_index "read_marks", ["user_id", "readable_type", "readable_id"], :name => "index_read_marks_on_user_id_and_readable_type_and_readable_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_listings", :force => true do |t|
    t.integer  "site_id"
    t.integer  "listing_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "site_listings", ["site_id", "listing_id"], :name => "index_org_listings_on_org_id_and_listing_id", :unique => true

  create_table "site_users", :force => true do |t|
    t.integer  "site_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "site_users", ["site_id", "user_id"], :name => "index_org_users_on_org_id_and_user_id", :unique => true

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.string   "org_type"
    t.string   "status"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "institution_id"
  end

  add_index "sites", ["institution_id"], :name => "index_organizations_on_institution_id"

  create_table "states", :force => true do |t|
    t.string "code"
    t.string "state_name"
    t.float  "sortkey"
    t.string "hide"
    t.string "status"
  end

  create_table "temp_listings", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "alias_name"
    t.integer  "category_id"
    t.integer  "site_id"
    t.integer  "seller_id"
    t.integer  "transaction_id"
    t.integer  "buyer_id"
    t.float    "price"
    t.string   "show_alias_flg"
    t.string   "show_phone_flg"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "pixi_id"
    t.string   "parent_pixi_id"
    t.string   "edited_by"
    t.datetime "edited_dt"
    t.string   "post_ip"
  end

  add_index "temp_listings", ["parent_pixi_id"], :name => "index_temp_listings_on_parent_pixi_id"
  add_index "temp_listings", ["pixi_id"], :name => "index_temp_listings_on_pixi_id", :unique => true
  add_index "temp_listings", ["status"], :name => "index_temp_listings_on_status"

  create_table "transaction_details", :force => true do |t|
    t.integer  "transaction_id"
    t.string   "item_name"
    t.integer  "quantity"
    t.float    "price"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "transaction_details", ["transaction_id"], :name => "index_transaction_details_on_transaction_id"

  create_table "transactions", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "email"
    t.string   "home_phone"
    t.string   "work_phone"
    t.integer  "credit_card_no"
    t.string   "promo_code"
    t.string   "country"
    t.string   "payment_type"
    t.string   "code"
    t.string   "description"
    t.float    "amt"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
    t.string   "token"
    t.string   "confirmation_no"
    t.string   "status"
    t.float    "convenience_fee"
    t.float    "processing_fee"
    t.string   "transaction_type"
  end

  add_index "transactions", ["code"], :name => "index_transactions_on_code"
  add_index "transactions", ["confirmation_no"], :name => "index_transactions_on_confirmation_no"
  add_index "transactions", ["transaction_type"], :name => "index_transactions_on_transaction_type"
  add_index "transactions", ["user_id"], :name => "index_transactions_on_user_id"

  create_table "user_interests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "interest_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "user_interests", ["user_id", "interest_id"], :name => "index_user_interests_on_user_id_and_interest_id", :unique => true

  create_table "user_pixi_points", :force => true do |t|
    t.integer  "user_id"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_pixi_points", ["user_id", "code", "created_at"], :name => "index_user_pixi_points_on_user_id_and_code_and_created_at"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.date     "birth_date"
    t.string   "gender"
    t.boolean  "fb_user"
    t.string   "provider"
    t.string   "uid"
    t.string   "status"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
