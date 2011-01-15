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

ActiveRecord::Schema.define(:version => 20110109015355) do

  create_table "categories", :force => true do |t|
    t.string  "cached_slug"
    t.string  "name"
    t.text    "description"
    t.integer "tools_count",                :default => 0
    t.string  "excerpt",     :limit => 140
  end

  add_index "categories", ["cached_slug"], :name => "index_categories_on_cached_slug", :unique => true
  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["locked_by"], :name => "delayed_jobs_locked_by"
  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "owners", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "ownable_id"
    t.string   "ownable_type"
    t.integer  "level"
  end

  add_index "owners", ["user_id", "ownable_id", "ownable_type"], :name => "index_owners_on_user_id_and_ownable_id_and_ownable_type"

  create_table "sites", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.datetime "ranks_updated_at"
    t.integer  "alexa_us_rank",     :limit => 8
    t.integer  "alexa_global_rank", :limit => 8
    t.integer  "google_pagerank"
    t.string   "excerpt",           :limit => 140
    t.integer  "tools_count",                      :default => 0
  end

  add_index "sites", ["cached_slug"], :name => "index_sites_on_cached_slug", :unique => true
  add_index "sites", ["title"], :name => "index_sites_on_title"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "sources", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.string   "url"
    t.text     "description"
    t.integer  "sourceable_id"
    t.string   "sourceable_type"
  end

  add_index "sources", ["sourceable_id", "sourceable_type"], :name => "index_sources_on_sourceable_id_and_sourceable_type"

  create_table "tools", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.string   "name"
    t.string   "url"
    t.integer  "category_id"
    t.text     "description"
    t.integer  "sites_count",                :default => 0
    t.string   "excerpt",     :limit => 140
  end

  add_index "tools", ["cached_slug"], :name => "index_tools_on_cached_slug", :unique => true
  add_index "tools", ["category_id"], :name => "index_tools_on_category_id"
  add_index "tools", ["name"], :name => "index_tools_on_name"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "authentication_token"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "usings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tool_id"
    t.text     "description"
    t.integer  "site_id",     :null => false
  end

end
