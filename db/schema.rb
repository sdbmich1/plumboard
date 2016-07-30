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

ActiveRecord::Schema.define(version: 20160712171531) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,   default: 0
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "authentication_token",   limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admins", ["authentication_token"], name: "index_admins_on_authentication_token", unique: true, using: :btree
  add_index "admins", ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true, using: :btree

  create_table "bank_accounts", force: :cascade do |t|
    t.string   "token",              limit: 255
    t.integer  "user_id",            limit: 4
    t.string   "acct_no",            limit: 255
    t.string   "acct_name",          limit: 255
    t.string   "acct_type",          limit: 255
    t.string   "status",             limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "description",        limit: 255
    t.string   "bank_name",          limit: 255
    t.string   "default_flg",        limit: 255
    t.string   "currency_type_code", limit: 255
    t.string   "country_code",       limit: 255
  end

  add_index "bank_accounts", ["user_id"], name: "index_bank_accounts_on_user_id", using: :btree

  create_table "buyers_listings", id: false, force: :cascade do |t|
    t.integer "listing_id", limit: 4
    t.integer "user_id",    limit: 4
  end

  add_index "buyers_listings", ["listing_id", "user_id"], name: "index_buyers_listings_on_listing_id_and_user_id", using: :btree
  add_index "buyers_listings", ["user_id"], name: "index_buyers_listings_on_user_id", using: :btree

  create_table "card_accounts", force: :cascade do |t|
    t.string   "token",            limit: 255
    t.string   "card_no",          limit: 255
    t.string   "card_type",        limit: 255
    t.integer  "expiration_month", limit: 4
    t.integer  "expiration_year",  limit: 4
    t.string   "status",           limit: 255
    t.integer  "user_id",          limit: 4
    t.string   "description",      limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "zip",              limit: 255
    t.string   "default_flg",      limit: 255
    t.string   "card_token",       limit: 255
  end

  add_index "card_accounts", ["card_no"], name: "index_card_accounts_on_card_no", using: :btree
  add_index "card_accounts", ["user_id"], name: "index_card_accounts_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "category_type_code", limit: 255
    t.string   "status",             limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "pixi_type",          limit: 255
  end

  add_index "categories", ["status"], name: "index_categories_on_status", using: :btree

  create_table "categories_listings", id: false, force: :cascade do |t|
    t.integer "listing_id",  limit: 4
    t.integer "category_id", limit: 4
  end

  add_index "categories_listings", ["category_id"], name: "index_categories_listings_on_category_id", using: :btree
  add_index "categories_listings", ["listing_id", "category_id"], name: "index_categories_listings_on_listing_id_and_category_id", using: :btree

  create_table "categories_temp_listings", id: false, force: :cascade do |t|
    t.integer "temp_listing_id", limit: 4
    t.integer "category_id",     limit: 4
  end

  add_index "categories_temp_listings", ["category_id"], name: "index_categories_temp_listings_on_category_id", using: :btree
  add_index "categories_temp_listings", ["temp_listing_id", "category_id"], name: "cat_tmp_index", using: :btree

  create_table "category_types", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "status",     limit: 255
    t.string   "hide",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "pixi_id",    limit: 255
    t.integer  "user_id",    limit: 4
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "comments", ["pixi_id"], name: "index_comments_on_pixi_id", using: :btree

  create_table "condition_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "description", limit: 255
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "address",          limit: 255
    t.string   "address2",         limit: 255
    t.string   "city",             limit: 255
    t.string   "state",            limit: 255
    t.string   "zip",              limit: 255
    t.string   "home_phone",       limit: 255
    t.string   "work_phone",       limit: 255
    t.string   "mobile_phone",     limit: 255
    t.string   "website",          limit: 255
    t.integer  "contactable_id",   limit: 4
    t.string   "contactable_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "country",          limit: 255
    t.float    "lng",              limit: 24
    t.float    "lat",              limit: 24
    t.string   "county",           limit: 255
    t.string   "place",            limit: 255
  end

  add_index "contacts", ["city", "state"], name: "index_contacts_on_city_and_state", using: :btree
  add_index "contacts", ["contactable_id"], name: "index_contacts_on_contactable_id", using: :btree
  add_index "contacts", ["contactable_type"], name: "index_contacts_on_contactable_type", using: :btree
  add_index "contacts", ["lat"], name: "index_contacts_on_lat", using: :btree
  add_index "contacts", ["lng", "lat"], name: "index_contacts_on_long_and_lat", using: :btree

  create_table "conversations", force: :cascade do |t|
    t.string   "pixi_id",            limit: 255
    t.integer  "user_id",            limit: 4
    t.integer  "recipient_id",       limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "status",             limit: 255
    t.string   "recipient_status",   limit: 255
    t.integer  "active_posts_count", limit: 4
  end

  add_index "conversations", ["pixi_id"], name: "index_conversations_on_pixi_id", using: :btree
  add_index "conversations", ["recipient_id"], name: "index_conversations_on_recipient_id", using: :btree
  add_index "conversations", ["recipient_status"], name: "index_conversations_on_recipient_status", using: :btree
  add_index "conversations", ["status"], name: "index_conversations_on_status", using: :btree
  add_index "conversations", ["user_id"], name: "index_conversations_on_user_id", using: :btree

  create_table "currency_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "currency_types", ["code"], name: "index_currency_types_on_code", using: :btree

  create_table "date_ranges", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "status",     limit: 255
    t.string   "hide",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "token",      limit: 255
    t.string   "platform",   limit: 255
    t.string   "status",     limit: 255
    t.boolean  "vibrate"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "event_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.string   "subject",       limit: 255
    t.text     "description",   limit: 65535
    t.string   "status",        limit: 255
    t.string   "question_type", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "favorite_sellers", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "seller_id",  limit: 4
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "favorite_sellers", ["seller_id"], name: "index_favorite_sellers_on_seller_id", using: :btree
  add_index "favorite_sellers", ["status"], name: "index_favorite_sellers_on_status", using: :btree
  add_index "favorite_sellers", ["user_id"], name: "index_favorite_sellers_on_user_id", using: :btree

  create_table "feeds", force: :cascade do |t|
    t.integer  "site_id",     limit: 4
    t.string   "site_name",   limit: 255
    t.string   "url",         limit: 255
    t.string   "status",      limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "feeds", ["site_id"], name: "index_feeds_on_site_id", using: :btree

  create_table "fulfillment_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "fulfillment_types", ["code"], name: "index_fulfillment_types_on_code", using: :btree

  create_table "inquiries", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.text     "comments",   limit: 65535
    t.string   "code",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "status",     limit: 255
  end

  add_index "inquiries", ["email"], name: "index_inquiries_on_email", using: :btree
  add_index "inquiries", ["user_id"], name: "index_inquiries_on_user_id", using: :btree

  create_table "inquiry_types", force: :cascade do |t|
    t.string   "code",         limit: 255
    t.string   "subject",      limit: 255
    t.string   "status",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "contact_type", limit: 255
  end

  add_index "inquiry_types", ["code"], name: "index_inquiry_types_on_code", using: :btree

  create_table "interests", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "interests", ["name"], name: "index_interests_on_name", using: :btree

  create_table "invoice_details", force: :cascade do |t|
    t.integer  "invoice_id",            limit: 4
    t.string   "pixi_id",               limit: 255
    t.integer  "quantity",              limit: 4
    t.float    "price",                 limit: 24
    t.float    "subtotal",              limit: 24
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "invoice_details", ["invoice_id", "pixi_id"], name: "index_invoice_details_on_invoice_id_and_pixi_id", using: :btree
  add_index "invoice_details", ["pixi_id"], name: "index_invoice_details_on_pixi_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.string   "pixi_id",               limit: 255
    t.integer  "seller_id",             limit: 4
    t.integer  "buyer_id",              limit: 4
    t.integer  "quantity",              limit: 4
    t.float    "price",                 limit: 24
    t.float    "amount",                limit: 24
    t.text     "comment",               limit: 65535
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "status",                limit: 255
    t.float    "sales_tax",             limit: 24
    t.datetime "inv_date"
    t.float    "subtotal",              limit: 24
    t.float    "tax_total",             limit: 24
    t.integer  "transaction_id",        limit: 4
    t.integer  "bank_account_id",       limit: 4
    t.boolean  "delta"
    t.float    "ship_amt",              limit: 24
    t.float    "other_amt",             limit: 24
    t.string   "promo_code",            limit: 255
    t.integer  "invoice_details_count", limit: 4
  end

  add_index "invoices", ["bank_account_id"], name: "index_invoices_on_bank_account_id", using: :btree
  add_index "invoices", ["pixi_id", "buyer_id", "seller_id"], name: "index_invoices_on_pixi_id_and_buyer_id_and_seller_id", using: :btree
  add_index "invoices", ["status"], name: "index_invoices_on_status", using: :btree
  add_index "invoices", ["transaction_id"], name: "index_invoices_on_transaction_id", using: :btree

  create_table "invoices_listings", id: false, force: :cascade do |t|
    t.integer "listing_id", limit: 4
    t.integer "invoice_id", limit: 4
  end

  add_index "invoices_listings", ["invoice_id"], name: "index_invoices_listings_on_invoice_id", using: :btree
  add_index "invoices_listings", ["listing_id", "invoice_id"], name: "index_invoices_listings_on_listing_id_and_invoice_id", using: :btree

  create_table "job_types", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "job_name",   limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "job_types", ["code"], name: "index_job_types_on_code", using: :btree

  create_table "listing_details", force: :cascade do |t|
    t.string   "pixi_id",       limit: 255
    t.integer  "site_id",       limit: 4
    t.string   "color",         limit: 255
    t.string   "item_size",     limit: 255
    t.integer  "quantity",      limit: 4
    t.string   "other_id",      limit: 255
    t.string   "delivery_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "listing_details", ["pixi_id"], name: "index_listing_details_on_pixi_id", using: :btree
  add_index "listing_details", ["site_id"], name: "index_listing_details_on_site_id", using: :btree

  create_table "listings", force: :cascade do |t|
    t.string   "title",                 limit: 255
    t.integer  "category_id",           limit: 4
    t.text     "description",           limit: 65535
    t.string   "status",                limit: 255
    t.integer  "seller_id",             limit: 4
    t.integer  "buyer_id",              limit: 4
    t.float    "price",                 limit: 24
    t.string   "show_alias_flg",        limit: 255
    t.string   "show_phone_flg",        limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "alias_name",            limit: 255
    t.datetime "start_date"
    t.integer  "site_id",               limit: 4
    t.datetime "end_date"
    t.integer  "transaction_id",        limit: 4
    t.string   "pixi_id",               limit: 255
    t.string   "edited_by",             limit: 255
    t.datetime "edited_dt"
    t.string   "post_ip",               limit: 255
    t.string   "compensation",          limit: 255
    t.float    "lng",                   limit: 24
    t.float    "lat",                   limit: 24
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built",            limit: 4
    t.integer  "pixan_id",              limit: 4
    t.string   "job_type_code",         limit: 255
    t.string   "explanation",           limit: 255
    t.boolean  "delta"
    t.string   "event_type_code",       limit: 255
    t.boolean  "repost_flg"
    t.string   "condition_type_code",   limit: 255
    t.string   "color",                 limit: 255
    t.integer  "quantity",              limit: 4
    t.integer  "mileage",               limit: 4
    t.string   "other_id",              limit: 255
    t.string   "item_type",             limit: 255
    t.string   "item_size",             limit: 255
    t.integer  "bed_no",                limit: 4
    t.integer  "bath_no",               limit: 4
    t.string   "term",                  limit: 255
    t.datetime "avail_date"
    t.boolean  "buy_now_flg"
    t.string   "external_url",          limit: 255
    t.integer  "ref_id",                limit: 4
    t.float    "est_ship_cost",         limit: 24
    t.float    "sales_tax",             limit: 24
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "listings", ["avail_date"], name: "index_listings_on_avail_date", using: :btree
  add_index "listings", ["category_id"], name: "index_listings_on_category_id", using: :btree
  add_index "listings", ["condition_type_code"], name: "index_listings_on_condition_type_code", using: :btree
  add_index "listings", ["end_date", "start_date"], name: "index_listings_on_end_date_and_start_date", using: :btree
  add_index "listings", ["event_start_date", "event_end_date"], name: "index_listings_on_event_start_date_and_event_end_date", using: :btree
  add_index "listings", ["event_type_code"], name: "index_listings_on_event_type_code", using: :btree
  add_index "listings", ["fulfillment_type_code"], name: "index_listings_on_fulfillment_type_code", using: :btree
  add_index "listings", ["job_type_code"], name: "index_listings_on_job_type", using: :btree
  add_index "listings", ["lng", "lat"], name: "index_listings_on_lng_and_lat", using: :btree
  add_index "listings", ["pixan_id"], name: "index_listings_on_pixan_id", using: :btree
  add_index "listings", ["pixi_id"], name: "index_listings_on_pixi_id", unique: true, using: :btree
  add_index "listings", ["ref_id"], name: "index_listings_on_ref_id", using: :btree
  add_index "listings", ["site_id", "seller_id", "start_date"], name: "index_listings_on_org_id_and_seller_id_and_start_date", using: :btree
  add_index "listings", ["status"], name: "index_listings_on_status", using: :btree
  add_index "listings", ["term"], name: "index_listings_on_term", using: :btree
  add_index "listings", ["transaction_id"], name: "index_listings_on_transaction_id", using: :btree

  create_table "listings_sites", id: false, force: :cascade do |t|
    t.integer "listing_id", limit: 4
    t.integer "site_id",    limit: 4
  end

  add_index "listings_sites", ["listing_id", "site_id"], name: "index_listings_sites_on_listing_id_and_site_id", using: :btree
  add_index "listings_sites", ["site_id"], name: "index_listings_sites_on_site_id", using: :btree

  create_table "listings_transactions", id: false, force: :cascade do |t|
    t.integer "listing_id",     limit: 4
    t.integer "transaction_id", limit: 4
  end

  add_index "listings_transactions", ["listing_id", "transaction_id"], name: "index_listings_transactions_on_listing_id_and_transaction_id", using: :btree
  add_index "listings_transactions", ["transaction_id"], name: "index_listings_transactions_on_transaction_id", using: :btree

  create_table "message_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "description", limit: 255
    t.string   "recipient",   limit: 255
    t.string   "status",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "device_id",         limit: 4
    t.string   "message_type_code", limit: 255
    t.string   "content",           limit: 255
    t.string   "priority",          limit: 255
    t.text     "reg_id",            limit: 65535
    t.string   "collapse_key",      limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "old_listings", force: :cascade do |t|
    t.string   "title",                 limit: 255
    t.integer  "user_id",               limit: 4
    t.string   "pixi_id",               limit: 255
    t.integer  "category_id",           limit: 4
    t.text     "description",           limit: 65535
    t.string   "status",                limit: 255
    t.integer  "seller_id",             limit: 4
    t.integer  "buyer_id",              limit: 4
    t.float    "price",                 limit: 24
    t.string   "show_alias_flg",        limit: 255
    t.string   "show_phone_flg",        limit: 255
    t.string   "alias_name",            limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "site_id",               limit: 4
    t.integer  "transaction_id",        limit: 4
    t.string   "edited_by",             limit: 255
    t.datetime "edited_dt"
    t.string   "post_ip",               limit: 255
    t.string   "compensation",          limit: 255
    t.float    "lng",                   limit: 24
    t.float    "lat",                   limit: 24
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built",            limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "pixan_id",              limit: 4
    t.string   "job_type_code",         limit: 255
    t.string   "explanation",           limit: 255
    t.string   "event_type_code",       limit: 255
    t.integer  "bed_no",                limit: 4
    t.integer  "bath_no",               limit: 4
    t.string   "term",                  limit: 255
    t.datetime "avail_date"
    t.boolean  "buy_now_flg"
    t.string   "external_url",          limit: 255
    t.integer  "ref_id",                limit: 4
    t.float    "est_ship_cost",         limit: 24
    t.float    "sales_tax",             limit: 24
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "old_listings", ["category_id"], name: "index_old_listings_on_category_id", using: :btree
  add_index "old_listings", ["event_type_code"], name: "index_old_listings_on_event_type_code", using: :btree
  add_index "old_listings", ["fulfillment_type_code"], name: "index_old_listings_on_fulfillment_type_code", using: :btree
  add_index "old_listings", ["pixan_id"], name: "index_old_listings_on_pixan_id", using: :btree
  add_index "old_listings", ["pixi_id"], name: "index_old_listings_on_pixi_id", using: :btree
  add_index "old_listings", ["title"], name: "index_old_listings_on_title", using: :btree
  add_index "old_listings", ["user_id"], name: "index_old_listings_on_user_id", using: :btree

  create_table "pictures", force: :cascade do |t|
    t.string   "delete_flg",         limit: 255
    t.integer  "imageable_id",       limit: 4
    t.string   "imageable_type",     limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.boolean  "processing"
    t.string   "direct_upload_url",  limit: 255
    t.string   "photo_file_path",    limit: 255
    t.boolean  "dup_flg"
  end

  add_index "pictures", ["imageable_id", "imageable_type"], name: "index_pictures_on_imageable_id_and_imageable_type", using: :btree
  add_index "pictures", ["processing"], name: "index_pictures_on_processing", using: :btree

  create_table "pixi_asks", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "pixi_id",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "pixi_likes", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "pixi_id",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "pixi_likes", ["user_id", "pixi_id"], name: "index_pixi_likes_on_user_id_and_pixi_id", using: :btree

  create_table "pixi_payments", force: :cascade do |t|
    t.string   "pixi_id",         limit: 255
    t.integer  "transaction_id",  limit: 4
    t.integer  "invoice_id",      limit: 4
    t.string   "token",           limit: 255
    t.integer  "seller_id",       limit: 4
    t.integer  "buyer_id",        limit: 4
    t.float    "amount",          limit: 24
    t.float    "pixi_fee",        limit: 24
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "confirmation_no", limit: 255
  end

  add_index "pixi_payments", ["confirmation_no"], name: "index_pixi_payments_on_confirmation_no", using: :btree
  add_index "pixi_payments", ["pixi_id", "seller_id", "buyer_id"], name: "index_pixi_payments_on_pixi_id_and_seller_id_and_buyer_id", using: :btree
  add_index "pixi_payments", ["pixi_id", "transaction_id", "invoice_id"], name: "index_pixi_payments_on_pid_txn_id_inv_id", using: :btree

  create_table "pixi_points", force: :cascade do |t|
    t.integer  "value",         limit: 4
    t.string   "action_name",   limit: 255
    t.string   "category_name", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "code",          limit: 255
  end

  add_index "pixi_points", ["code"], name: "index_pixi_points_on_code", using: :btree

  create_table "pixi_post_details", force: :cascade do |t|
    t.integer  "pixi_post_id", limit: 4
    t.string   "pixi_id",      limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "pixi_post_details", ["pixi_id"], name: "index_pixi_post_details_on_pixi_id", using: :btree
  add_index "pixi_post_details", ["pixi_post_id", "pixi_id"], name: "index_pixi_post_details_on_pixi_post_id_and_pixi_id", using: :btree

  create_table "pixi_post_zips", force: :cascade do |t|
    t.integer  "zip",        limit: 4
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "pixi_post_zips", ["zip"], name: "index_pixi_post_zips_on_zip", using: :btree

  create_table "pixi_posts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4
    t.datetime "preferred_date"
    t.datetime "preferred_time"
    t.datetime "alt_date"
    t.datetime "alt_time"
    t.datetime "appt_date"
    t.datetime "appt_time"
    t.datetime "completed_date"
    t.datetime "completed_time"
    t.string   "pixi_id",        limit: 255
    t.integer  "pixan_id",       limit: 4
    t.integer  "quantity",       limit: 4
    t.string   "description",    limit: 255
    t.float    "value",          limit: 24
    t.string   "address",        limit: 255
    t.string   "city",           limit: 255
    t.string   "state",          limit: 255
    t.string   "zip",            limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "status",         limit: 255
    t.string   "home_phone",     limit: 255
    t.string   "mobile_phone",   limit: 255
    t.string   "address2",       limit: 255
    t.text     "comments",       limit: 65535
    t.integer  "editor_id",      limit: 4
    t.string   "country",        limit: 255
  end

  add_index "pixi_posts", ["editor_id"], name: "index_pixi_posts_on_editor_id", using: :btree
  add_index "pixi_posts", ["pixan_id"], name: "index_pixi_posts_on_pixan_id", using: :btree
  add_index "pixi_posts", ["pixi_id"], name: "index_pixi_posts_on_pixi_id", using: :btree
  add_index "pixi_posts", ["status"], name: "index_pixi_posts_on_status", using: :btree
  add_index "pixi_posts", ["user_id"], name: "index_pixi_posts_on_user_id", using: :btree

  create_table "pixi_wants", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "pixi_id",               limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "quantity",              limit: 4
    t.string   "status",                limit: 255
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "pixi_wants", ["fulfillment_type_code"], name: "index_pixi_wants_on_fulfillment_type_code", using: :btree
  add_index "pixi_wants", ["status"], name: "index_pixi_wants_on_status", using: :btree
  add_index "pixi_wants", ["user_id", "pixi_id"], name: "index_pixi_wants_on_user_id_and_pixi_id", using: :btree

  create_table "plans", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "interval",   limit: 255
    t.float    "price",      limit: 24
    t.string   "status",     limit: 255
    t.string   "stripe_id",  limit: 255
    t.integer  "trial_days", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "plans", ["name"], name: "index_plans_on_name", using: :btree

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.text     "content",          limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "pixi_id",          limit: 255
    t.integer  "recipient_id",     limit: 4
    t.string   "msg_type",         limit: 255
    t.integer  "conversation_id",  limit: 4
    t.string   "status",           limit: 255
    t.string   "recipient_status", limit: 255
  end

  add_index "posts", ["conversation_id"], name: "index_posts_on_conversation_id", using: :btree
  add_index "posts", ["msg_type"], name: "index_posts_on_msg_type", using: :btree
  add_index "posts", ["pixi_id"], name: "index_posts_on_pixi_id", using: :btree
  add_index "posts", ["recipient_status"], name: "index_posts_on_recipient_status", using: :btree
  add_index "posts", ["status"], name: "index_posts_on_status", using: :btree
  add_index "posts", ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at", unique: true, using: :btree

  create_table "preferences", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.string   "zip",                   limit: 255
    t.string   "email_msg_flg",         limit: 255
    t.string   "mobile_msg_flg",        limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "buy_now_flg"
    t.float    "sales_tax",             limit: 24
    t.float    "ship_amt",              limit: 24
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "preferences", ["user_id", "zip"], name: "index_preferences_on_user_id_and_zip", using: :btree

  create_table "promo_codes", force: :cascade do |t|
    t.string   "code",            limit: 255
    t.string   "promo_name",      limit: 255
    t.string   "description",     limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "status",          limit: 255
    t.integer  "max_redemptions", limit: 4
    t.integer  "amountOff",       limit: 4
    t.integer  "percentOff",      limit: 4
    t.string   "currency",        limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "promo_type",      limit: 255
    t.integer  "site_id",         limit: 4
  end

  add_index "promo_codes", ["code", "status"], name: "index_promo_codes_on_code_and_status", using: :btree
  add_index "promo_codes", ["end_date", "start_date"], name: "index_promo_codes_on_end_date_and_start_date", using: :btree
  add_index "promo_codes", ["site_id"], name: "index_promo_codes_on_site_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "seller_id",  limit: 4
    t.integer  "user_id",    limit: 4
    t.text     "comments",   limit: 65535
    t.integer  "value",      limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "pixi_id",    limit: 255
  end

  add_index "ratings", ["pixi_id"], name: "index_ratings_on_pixi_id", using: :btree
  add_index "ratings", ["seller_id", "user_id"], name: "index_ratings_on_seller_id_and_user_id", using: :btree

  create_table "read_marks", force: :cascade do |t|
    t.integer  "readable_id",   limit: 4
    t.integer  "reader_id",     limit: 4,   null: false
    t.string   "readable_type", limit: 20,  null: false
    t.datetime "timestamp"
    t.string   "reader_type",   limit: 255
  end

  add_index "read_marks", ["reader_id", "reader_type", "readable_type", "readable_id"], name: "read_marks_reader_readable_index", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "resource_id",   limit: 4
    t.string   "resource_type", limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "saved_listings", force: :cascade do |t|
    t.string   "pixi_id",    limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "status",     limit: 255
  end

  add_index "saved_listings", ["pixi_id", "user_id"], name: "index_saved_listings_on_pixi_id_and_user_id", using: :btree
  add_index "saved_listings", ["status"], name: "index_saved_listings_on_status", using: :btree

  create_table "saved_pixis", force: :cascade do |t|
    t.string   "pixi_id",    limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "saved_pixis", ["pixi_id", "user_id"], name: "index_saved_pixis_on_pixi_id_and_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "ship_addresses", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.string   "recipient_first_name", limit: 255
    t.string   "recipient_last_name",  limit: 255
    t.string   "recipient_email",      limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "ship_addresses", ["user_id"], name: "index_ship_addresses_on_user_id", using: :btree

  create_table "site_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "site_types", ["code"], name: "index_org_types_on_code", using: :btree

  create_table "sites", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "site_type_code", limit: 255
    t.string   "status",         limit: 255
    t.string   "email",          limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "institution_id", limit: 4
    t.string   "url",            limit: 255
    t.string   "description",    limit: 255
  end

  add_index "sites", ["institution_id"], name: "index_organizations_on_institution_id", using: :btree
  add_index "sites", ["name"], name: "index_sites_on_name", using: :btree
  add_index "sites", ["status", "site_type_code"], name: "index_sites_on_status_and_org_type", using: :btree
  add_index "sites", ["status"], name: "index_sites_on_status", using: :btree
  add_index "sites", ["url"], name: "index_sites_on_url", using: :btree

  create_table "sites_temp_listings", id: false, force: :cascade do |t|
    t.integer "temp_listing_id", limit: 4
    t.integer "site_id",         limit: 4
    t.integer "quantity",        limit: 4
  end

  add_index "sites_temp_listings", ["site_id"], name: "index_sites_temp_listings_on_site_id", using: :btree
  add_index "sites_temp_listings", ["temp_listing_id", "site_id"], name: "index_sites_temp_listings_on_temp_listing_id_and_site_id", using: :btree

  create_table "states", force: :cascade do |t|
    t.string "code",       limit: 255
    t.string "state_name", limit: 255
    t.float  "sortkey",    limit: 53
    t.string "hide",       limit: 255
    t.string "status",     limit: 255
  end

  create_table "status_types", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.string   "hide",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "status_types", ["hide"], name: "index_status_types_on_hide", using: :btree

  create_table "stock_images", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.string   "category_type_code", limit: 255
    t.string   "file_name",          limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "subcategories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "category_id",      limit: 4
    t.string   "status",           limit: 255
    t.string   "subcategory_type", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "subcategories", ["category_id"], name: "index_subcategories_on_category_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "plan_id",         limit: 4
    t.integer  "user_id",         limit: 4
    t.integer  "card_account_id", limit: 4
    t.string   "stripe_id",       limit: 255
    t.string   "status",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "temp_listings", force: :cascade do |t|
    t.string   "title",                 limit: 255
    t.text     "description",           limit: 65535
    t.string   "status",                limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "alias_name",            limit: 255
    t.integer  "category_id",           limit: 4
    t.integer  "site_id",               limit: 4
    t.integer  "seller_id",             limit: 4
    t.integer  "transaction_id",        limit: 4
    t.integer  "buyer_id",              limit: 4
    t.float    "price",                 limit: 24
    t.string   "show_alias_flg",        limit: 255
    t.string   "show_phone_flg",        limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "pixi_id",               limit: 255
    t.string   "parent_pixi_id",        limit: 255
    t.string   "edited_by",             limit: 255
    t.datetime "edited_dt"
    t.string   "post_ip",               limit: 255
    t.string   "compensation",          limit: 255
    t.float    "lng",                   limit: 24
    t.float    "lat",                   limit: 24
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built",            limit: 4
    t.integer  "pixan_id",              limit: 4
    t.string   "job_type_code",         limit: 255
    t.string   "explanation",           limit: 255
    t.string   "event_type_code",       limit: 255
    t.boolean  "delta"
    t.boolean  "repost_flg"
    t.string   "condition_type_code",   limit: 255
    t.string   "color",                 limit: 255
    t.integer  "quantity",              limit: 4
    t.integer  "mileage",               limit: 4
    t.string   "other_id",              limit: 255
    t.string   "item_type",             limit: 255
    t.string   "item_size",             limit: 255
    t.integer  "bed_no",                limit: 4
    t.integer  "bath_no",               limit: 4
    t.string   "term",                  limit: 255
    t.datetime "avail_date"
    t.boolean  "buy_now_flg"
    t.string   "external_url",          limit: 255
    t.integer  "ref_id",                limit: 4
    t.float    "est_ship_cost",         limit: 24
    t.float    "sales_tax",             limit: 24
    t.string   "fulfillment_type_code", limit: 255
  end

  add_index "temp_listings", ["condition_type_code"], name: "index_temp_listings_on_condition_type_code", using: :btree
  add_index "temp_listings", ["fulfillment_type_code"], name: "index_temp_listings_on_fulfillment_type_code", using: :btree
  add_index "temp_listings", ["pixi_id"], name: "index_temp_listings_on_pixi_id", unique: true, using: :btree
  add_index "temp_listings", ["status"], name: "index_temp_listings_on_status", using: :btree

  create_table "transaction_details", force: :cascade do |t|
    t.integer  "transaction_id", limit: 4
    t.string   "item_name",      limit: 255
    t.integer  "quantity",       limit: 4
    t.float    "price",          limit: 24
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "transaction_details", ["transaction_id"], name: "index_transaction_details_on_transaction_id", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.string   "first_name",           limit: 255
    t.string   "last_name",            limit: 255
    t.string   "address",              limit: 255
    t.string   "address2",             limit: 255
    t.string   "city",                 limit: 255
    t.string   "state",                limit: 255
    t.string   "zip",                  limit: 255
    t.string   "email",                limit: 255
    t.string   "home_phone",           limit: 255
    t.string   "work_phone",           limit: 255
    t.integer  "credit_card_no",       limit: 4
    t.string   "promo_code",           limit: 255
    t.string   "country",              limit: 255
    t.string   "payment_type",         limit: 255
    t.string   "code",                 limit: 255
    t.string   "description",          limit: 255
    t.float    "amt",                  limit: 24
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "user_id",              limit: 4
    t.string   "token",                limit: 255
    t.string   "confirmation_no",      limit: 255
    t.string   "status",               limit: 255
    t.float    "convenience_fee",      limit: 24
    t.float    "processing_fee",       limit: 24
    t.string   "transaction_type",     limit: 255
    t.string   "debit_token",          limit: 255
    t.string   "recipient_first_name", limit: 255
    t.string   "recipient_last_name",  limit: 255
    t.string   "recipient_email",      limit: 255
    t.string   "ship_address",         limit: 255
    t.string   "ship_address2",        limit: 255
    t.string   "ship_city",            limit: 255
    t.string   "ship_state",           limit: 255
    t.string   "ship_zip",             limit: 255
    t.string   "ship_country",         limit: 255
    t.string   "recipient_phone",      limit: 255
  end

  add_index "transactions", ["code"], name: "index_transactions_on_code", using: :btree
  add_index "transactions", ["confirmation_no"], name: "index_transactions_on_confirmation_no", using: :btree
  add_index "transactions", ["transaction_type"], name: "index_transactions_on_transaction_type", using: :btree
  add_index "transactions", ["updated_at"], name: "index_transactions_on_updated_at", using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "travel_modes", force: :cascade do |t|
    t.string   "mode",        limit: 255
    t.string   "travel_type", limit: 255
    t.string   "status",      limit: 255
    t.string   "hide",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "user_interests", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.integer  "interest_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "user_interests", ["user_id", "interest_id"], name: "index_user_interests_on_user_id_and_interest_id", unique: true, using: :btree

  create_table "user_pixi_points", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "user_pixi_points", ["user_id", "code", "created_at"], name: "index_user_pixi_points_on_user_id_and_code_and_created_at", using: :btree

  create_table "user_types", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "description", limit: 255
    t.string   "status",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "hide",        limit: 255
  end

  add_index "user_types", ["code"], name: "index_user_types_on_code", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                 limit: 255
    t.string   "last_name",                  limit: 255
    t.string   "email",                      limit: 255, default: "", null: false
    t.string   "encrypted_password",         limit: 255, default: "", null: false
    t.string   "reset_password_token",       limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",         limit: 255
    t.string   "last_sign_in_ip",            limit: 255
    t.string   "confirmation_token",         limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",          limit: 255
    t.integer  "failed_attempts",            limit: 4,   default: 0
    t.string   "unlock_token",               limit: 255
    t.datetime "locked_at"
    t.string   "authentication_token",       limit: 255
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.date     "birth_date"
    t.string   "gender",                     limit: 255
    t.boolean  "fb_user"
    t.string   "provider",                   limit: 255
    t.string   "uid",                        limit: 255
    t.string   "status",                     limit: 255
    t.string   "acct_token",                 limit: 255
    t.string   "user_type_code",             limit: 255
    t.string   "business_name",              limit: 255
    t.integer  "ref_id",                     limit: 4
    t.string   "url",                        limit: 255
    t.boolean  "guest"
    t.string   "description",                limit: 255
    t.integer  "active_listings_count",      limit: 4,   default: 0
    t.string   "cust_token",                 limit: 255
    t.integer  "ein",                        limit: 4
    t.integer  "ssn_last4",                  limit: 4
    t.integer  "active_card_accounts_count", limit: 4
  end

  add_index "users", ["acct_token"], name: "index_users_on_acct_token", using: :btree
  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["business_name"], name: "index_users_on_business_name", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["ref_id"], name: "index_users_on_ref_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["status"], name: "index_users_on_status", using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  add_index "users", ["url"], name: "index_users_on_url", unique: true, using: :btree
  add_index "users", ["user_type_code"], name: "index_users_on_user_type", using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "role_id", limit: 4
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

end
