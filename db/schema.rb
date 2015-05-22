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

ActiveRecord::Schema.define(:version => 20150514174659) do

  create_table "bank_accounts", :force => true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.string   "acct_no"
    t.string   "acct_name"
    t.string   "acct_type"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
    t.string   "bank_name"
    t.string   "default_flg"
  end

  add_index "bank_accounts", ["user_id"], :name => "index_bank_accounts_on_user_id"

  create_table "card_accounts", :force => true do |t|
    t.string   "token"
    t.string   "card_no"
    t.string   "card_type"
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.string   "status"
    t.integer  "user_id"
    t.string   "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "zip"
    t.string   "default_flg"
  end

  add_index "card_accounts", ["card_no"], :name => "index_card_accounts_on_card_no"
  add_index "card_accounts", ["user_id"], :name => "index_card_accounts_on_user_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.string   "category_type_code"
    t.string   "status"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "pixi_type"
  end

  create_table "category_types", :force => true do |t|
    t.string   "code"
    t.string   "status"
    t.string   "hide"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["pixi_id"], :name => "index_comments_on_pixi_id"

  create_table "condition_types", :force => true do |t|
    t.string   "code"
    t.string   "status"
    t.string   "hide"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "description"
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
    t.float    "lng"
    t.float    "lat"
    t.string   "county"
    t.string   "place"
  end

  add_index "contacts", ["city", "state"], :name => "index_contacts_on_city_and_state"
  add_index "contacts", ["contactable_id"], :name => "index_contacts_on_contactable_id"
  add_index "contacts", ["contactable_type"], :name => "index_contacts_on_contactable_type"
  add_index "contacts", ["lng", "lat"], :name => "index_contacts_on_long_and_lat"

  create_table "conversations", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "status"
    t.string   "recipient_status"
    t.integer  "posts_count"
  end

  add_index "conversations", ["pixi_id"], :name => "index_conversations_on_pixi_id"
  add_index "conversations", ["recipient_id"], :name => "index_conversations_on_recipient_id"
  add_index "conversations", ["recipient_status"], :name => "index_conversations_on_recipient_status"
  add_index "conversations", ["status"], :name => "index_conversations_on_status"
  add_index "conversations", ["user_id"], :name => "index_conversations_on_user_id"

  create_table "date_ranges", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "hide"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "event_types", :force => true do |t|
    t.string   "code"
    t.string   "status"
    t.string   "hide"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "faqs", :force => true do |t|
    t.string   "subject"
    t.text     "description"
    t.string   "status"
    t.string   "question_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "favorite_sellers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "seller_id"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "favorite_sellers", ["seller_id"], :name => "index_favorite_sellers_on_seller_id"
  add_index "favorite_sellers", ["user_id"], :name => "index_favorite_sellers_on_user_id"

  create_table "feeds", :force => true do |t|
    t.integer  "site_id"
    t.string   "site_name"
    t.string   "url"
    t.string   "status"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "feeds", ["site_id"], :name => "index_feeds_on_site_id"

  create_table "fulfillment_types", :force => true do |t|
    t.string   "code"
    t.string   "status"
    t.string   "hide"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "fulfillment_types", ["code"], :name => "index_fulfillment_types_on_code"

  create_table "inquiries", :force => true do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "comments"
    t.string   "code"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
  end

  add_index "inquiries", ["email"], :name => "index_inquiries_on_email"
  add_index "inquiries", ["user_id"], :name => "index_inquiries_on_user_id"

  create_table "inquiry_types", :force => true do |t|
    t.string   "code"
    t.string   "subject"
    t.string   "status"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "contact_type"
  end

  add_index "inquiry_types", ["code"], :name => "index_inquiry_types_on_code"

  create_table "interests", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "interests", ["name"], :name => "index_interests_on_name"

  create_table "invoice_details", :force => true do |t|
    t.integer  "invoice_id"
    t.string   "pixi_id"
    t.integer  "quantity"
    t.float    "price"
    t.float    "subtotal"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "invoice_details", ["invoice_id", "pixi_id"], :name => "index_invoice_details_on_invoice_id_and_pixi_id"
  add_index "invoice_details", ["pixi_id"], :name => "index_invoice_details_on_pixi_id"

  create_table "invoices", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.integer  "quantity"
    t.float    "price"
    t.float    "amount"
    t.text     "comment"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "status"
    t.float    "sales_tax"
    t.datetime "inv_date"
    t.float    "subtotal"
    t.float    "tax_total"
    t.integer  "transaction_id"
    t.integer  "bank_account_id"
    t.boolean  "delta"
    t.float    "ship_amt"
    t.float    "other_amt"
    t.string   "promo_code"
    t.integer  "invoice_details_count"
  end

  add_index "invoices", ["bank_account_id"], :name => "index_invoices_on_bank_account_id"
  add_index "invoices", ["pixi_id", "buyer_id", "seller_id"], :name => "index_invoices_on_pixi_id_and_buyer_id_and_seller_id"
  add_index "invoices", ["status"], :name => "index_invoices_on_status"
  add_index "invoices", ["transaction_id"], :name => "index_invoices_on_transaction_id"

  create_table "job_types", :force => true do |t|
    t.string   "code"
    t.string   "job_name"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "job_types", ["code"], :name => "index_job_types_on_code"

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
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "alias_name"
    t.datetime "start_date"
    t.integer  "site_id"
    t.datetime "end_date"
    t.integer  "transaction_id"
    t.string   "pixi_id"
    t.string   "edited_by"
    t.datetime "edited_dt"
    t.string   "post_ip"
    t.string   "compensation"
    t.float    "lng"
    t.float    "lat"
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built"
    t.integer  "pixan_id"
    t.string   "job_type_code"
    t.string   "explanation"
    t.boolean  "delta"
    t.string   "event_type_code"
    t.boolean  "repost_flg"
    t.string   "condition_type_code"
    t.string   "color"
    t.integer  "quantity"
    t.integer  "mileage"
    t.string   "other_id"
    t.string   "item_type"
    t.string   "item_size"
  end

  add_index "listings", ["category_id"], :name => "index_listings_on_category_id"
  add_index "listings", ["condition_type_code"], :name => "index_listings_on_condition_type_code"
  add_index "listings", ["end_date", "start_date"], :name => "index_listings_on_end_date_and_start_date"
  add_index "listings", ["event_start_date", "event_end_date"], :name => "index_listings_on_event_start_date_and_event_end_date"
  add_index "listings", ["event_type_code"], :name => "index_listings_on_event_type_code"
  add_index "listings", ["job_type_code"], :name => "index_listings_on_job_type"
  add_index "listings", ["lng", "lat"], :name => "index_listings_on_lng_and_lat"
  add_index "listings", ["pixan_id"], :name => "index_listings_on_pixan_id"
  add_index "listings", ["pixi_id"], :name => "index_listings_on_pixi_id", :unique => true
  add_index "listings", ["site_id", "seller_id", "start_date"], :name => "index_listings_on_org_id_and_seller_id_and_start_date"
  add_index "listings", ["status"], :name => "index_listings_on_status"
  add_index "listings", ["transaction_id"], :name => "index_listings_on_transaction_id"

  create_table "old_listings", :force => true do |t|
    t.string   "title"
    t.integer  "user_id"
    t.string   "pixi_id"
    t.integer  "category_id"
    t.text     "description"
    t.string   "status"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.float    "price"
    t.string   "show_alias_flg"
    t.string   "show_phone_flg"
    t.string   "alias_name"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "site_id"
    t.integer  "transaction_id"
    t.string   "edited_by"
    t.datetime "edited_dt"
    t.string   "post_ip"
    t.string   "compensation"
    t.float    "lng"
    t.float    "lat"
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "pixan_id"
    t.string   "job_type_code"
    t.string   "explanation"
    t.string   "event_type_code"
  end

  add_index "old_listings", ["category_id"], :name => "index_old_listings_on_category_id"
  add_index "old_listings", ["event_type_code"], :name => "index_old_listings_on_event_type_code"
  add_index "old_listings", ["pixan_id"], :name => "index_old_listings_on_pixan_id"
  add_index "old_listings", ["pixi_id"], :name => "index_old_listings_on_pixi_id"
  add_index "old_listings", ["title"], :name => "index_old_listings_on_title"
  add_index "old_listings", ["user_id"], :name => "index_old_listings_on_user_id"

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
    t.boolean  "processing"
    t.string   "direct_upload_url"
    t.string   "photo_file_path"
    t.boolean  "dup_flg"
  end

  add_index "pictures", ["imageable_id", "imageable_type"], :name => "index_pictures_on_imageable_id_and_imageable_type"
  add_index "pictures", ["processing"], :name => "index_pictures_on_processing"

  create_table "pixi_asks", :force => true do |t|
    t.integer  "user_id"
    t.string   "pixi_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pixi_likes", :force => true do |t|
    t.integer  "user_id"
    t.string   "pixi_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pixi_likes", ["user_id", "pixi_id"], :name => "index_pixi_likes_on_user_id_and_pixi_id"

  create_table "pixi_payments", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "transaction_id"
    t.integer  "invoice_id"
    t.string   "token"
    t.integer  "seller_id"
    t.integer  "buyer_id"
    t.float    "amount"
    t.float    "pixi_fee"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "confirmation_no"
  end

  add_index "pixi_payments", ["confirmation_no"], :name => "index_pixi_payments_on_confirmation_no"
  add_index "pixi_payments", ["pixi_id", "seller_id", "buyer_id"], :name => "index_pixi_payments_on_pixi_id_and_seller_id_and_buyer_id"
  add_index "pixi_payments", ["pixi_id", "transaction_id", "invoice_id"], :name => "index_pixi_payments_on_pixi_id_and_transaction_id_and_invoice_id"

  create_table "pixi_points", :force => true do |t|
    t.integer  "value"
    t.string   "action_name"
    t.string   "category_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "code"
  end

  add_index "pixi_points", ["code"], :name => "index_pixi_points_on_code"

  create_table "pixi_post_details", :force => true do |t|
    t.integer  "pixi_post_id"
    t.string   "pixi_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "pixi_post_details", ["pixi_id"], :name => "index_pixi_post_details_on_pixi_id"
  add_index "pixi_post_details", ["pixi_post_id", "pixi_id"], :name => "index_pixi_post_details_on_pixi_post_id_and_pixi_id"

  create_table "pixi_post_zips", :force => true do |t|
    t.integer  "zip"
    t.string   "city"
    t.string   "state"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pixi_post_zips", ["zip"], :name => "index_pixi_post_zips_on_zip"

  create_table "pixi_posts", :force => true do |t|
    t.integer  "user_id"
    t.datetime "preferred_date"
    t.datetime "preferred_time"
    t.datetime "alt_date"
    t.datetime "alt_time"
    t.datetime "appt_date"
    t.datetime "appt_time"
    t.datetime "completed_date"
    t.datetime "completed_time"
    t.string   "pixi_id"
    t.integer  "pixan_id"
    t.integer  "quantity"
    t.string   "description"
    t.float    "value"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "status"
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.string   "address2"
    t.text     "comments"
    t.integer  "editor_id"
    t.string   "country"
  end

  add_index "pixi_posts", ["editor_id"], :name => "index_pixi_posts_on_editor_id"
  add_index "pixi_posts", ["pixan_id"], :name => "index_pixi_posts_on_pixan_id"
  add_index "pixi_posts", ["pixi_id"], :name => "index_pixi_posts_on_pixi_id"
  add_index "pixi_posts", ["status"], :name => "index_pixi_posts_on_status"
  add_index "pixi_posts", ["user_id"], :name => "index_pixi_posts_on_user_id"

  create_table "pixi_wants", :force => true do |t|
    t.integer  "user_id"
    t.string   "pixi_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "quantity"
    t.string   "status"
  end

  add_index "pixi_wants", ["status"], :name => "index_pixi_wants_on_status"
  add_index "pixi_wants", ["user_id", "pixi_id"], :name => "index_pixi_wants_on_user_id_and_pixi_id"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "pixi_id"
    t.integer  "recipient_id"
    t.string   "msg_type"
    t.integer  "conversation_id"
    t.string   "status"
    t.string   "recipient_status"
  end

  add_index "posts", ["conversation_id"], :name => "index_posts_on_conversation_id"
  add_index "posts", ["msg_type"], :name => "index_posts_on_msg_type"
  add_index "posts", ["pixi_id"], :name => "index_posts_on_pixi_id"
  add_index "posts", ["recipient_status"], :name => "index_posts_on_recipient_status"
  add_index "posts", ["status"], :name => "index_posts_on_status"
  add_index "posts", ["user_id", "created_at"], :name => "index_posts_on_user_id_and_created_at", :unique => true

  create_table "preferences", :force => true do |t|
    t.integer  "user_id"
    t.string   "zip"
    t.string   "email_msg_flg"
    t.string   "mobile_msg_flg"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "preferences", ["user_id", "zip"], :name => "index_preferences_on_user_id_and_zip"

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

  create_table "ratings", :force => true do |t|
    t.integer  "seller_id"
    t.integer  "user_id"
    t.text     "comments"
    t.integer  "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "pixi_id"
  end

  add_index "ratings", ["pixi_id"], :name => "index_ratings_on_pixi_id"
  add_index "ratings", ["seller_id", "user_id"], :name => "index_ratings_on_seller_id_and_user_id"

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

  create_table "saved_listings", :force => true do |t|
    t.string   "pixi_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "status"
  end

  add_index "saved_listings", ["pixi_id", "user_id"], :name => "index_saved_listings_on_pixi_id_and_user_id"
  add_index "saved_listings", ["status"], :name => "index_saved_listings_on_status"

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

  create_table "status_types", :force => true do |t|
    t.string   "code"
    t.string   "hide"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subcategories", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.string   "status"
    t.string   "subcategory_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "subcategories", ["category_id"], :name => "index_subcategories_on_category_id"

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
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "pixi_id"
    t.string   "parent_pixi_id"
    t.string   "edited_by"
    t.datetime "edited_dt"
    t.string   "post_ip"
    t.string   "compensation"
    t.float    "lng"
    t.float    "lat"
    t.datetime "event_start_date"
    t.datetime "event_end_date"
    t.datetime "event_start_time"
    t.datetime "event_end_time"
    t.integer  "year_built"
    t.integer  "pixan_id"
    t.string   "job_type_code"
    t.string   "explanation"
    t.string   "event_type_code"
    t.boolean  "delta"
    t.boolean  "repost_flg"
    t.string   "condition_type_code"
    t.string   "color"
    t.integer  "quantity"
    t.integer  "mileage"
    t.string   "other_id"
    t.string   "item_type"
    t.string   "item_size"
  end

  add_index "temp_listings", ["condition_type_code"], :name => "index_temp_listings_on_condition_type_code"
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
    t.string   "debit_token"
  end

  add_index "transactions", ["code"], :name => "index_transactions_on_code"
  add_index "transactions", ["confirmation_no"], :name => "index_transactions_on_confirmation_no"
  add_index "transactions", ["transaction_type"], :name => "index_transactions_on_transaction_type"
  add_index "transactions", ["updated_at"], :name => "index_transactions_on_updated_at"
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

  create_table "user_types", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "hide"
  end

  add_index "user_types", ["code"], :name => "index_user_types_on_code"

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
    t.string   "acct_token"
    t.string   "user_type_code"
    t.string   "business_name"
    t.integer  "ref_id"
    t.string   "url"
    t.boolean  "guest"
    t.string   "description"
    t.integer  "active_listings_count",  :default => 0
  end

  add_index "users", ["acct_token"], :name => "index_users_on_acct_token"
  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["business_name"], :name => "index_users_on_business_name"
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["ref_id"], :name => "index_users_on_ref_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["url"], :name => "index_users_on_url", :unique => true
  add_index "users", ["user_type_code"], :name => "index_users_on_user_type"

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
