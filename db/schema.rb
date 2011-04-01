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

ActiveRecord::Schema.define(:version => 20110331221947) do

  create_table "authentications", :force => true do |t|
    t.integer "user_id"
    t.string  "provider"
    t.string  "uid"
  end

  add_index "authentications", ["user_id"], :name => "index_authentications_on_user_id"

  create_table "bookmark_annotations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "annotateable_type"
    t.integer  "annotateable_id"
    t.integer  "bookmark_id"
    t.text     "description"
  end

  create_table "bookmark_connections", :force => true do |t|
    t.datetime "created_at"
    t.integer  "bookmark_id"
    t.integer  "using_id"
  end

  add_index "bookmark_connections", ["bookmark_id"], :name => "index_bookmark_connections_on_bookmark_id"
  add_index "bookmark_connections", ["using_id"], :name => "index_bookmark_connections_on_using_id"

  create_table "bookmarks", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",                 :default => "Bookmark"
    t.integer  "parent_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "url"
    t.text     "description"
    t.text     "cached_tools"
    t.text     "cached_sites"
    t.text     "cached_connections"
    t.boolean  "has_favicon",          :default => false
    t.integer  "link_id"
    t.string   "cached_slug"
    t.boolean  "is_video",             :default => false
    t.boolean  "is_presentation",      :default => false
    t.string   "uid"
    t.integer  "user_bookmarks_count", :default => 0
  end

  add_index "bookmarks", ["user_id"], :name => "index_bookmarks_on_user_id"

  create_table "buildables", :force => true do |t|
    t.integer "tool_id"
    t.integer "category_id"
  end

  add_index "buildables", ["category_id"], :name => "index_buildables_on_category_id"
  add_index "buildables", ["tool_id"], :name => "index_buildables_on_tool_id"

  create_table "categories", :force => true do |t|
    t.string  "cached_slug"
    t.string  "name"
    t.text    "description"
    t.integer "tools_count",                :default => 0
    t.string  "excerpt",     :limit => 140
    t.string  "keyword"
  end

  add_index "categories", ["cached_slug"], :name => "index_categories_on_cached_slug", :unique => true
  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "claims", :force => true do |t|
    t.datetime "created_at"
    t.integer  "user_id"
    t.integer  "claimable_id"
    t.string   "claimable_type"
  end

  add_index "claims", ["claimable_id", "claimable_type"], :name => "index_claims_on_claimable_id_and_claimable_type"
  add_index "claims", ["user_id"], :name => "index_claims_on_user_id"

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

  create_table "favicons", :force => true do |t|
    t.string   "url"
    t.string   "uid"
    t.string   "favicon_file_name"
    t.string   "favicon_content_type"
    t.integer  "favicon_file_size"
    t.datetime "favicon_updated_at"
  end

  add_index "favicons", ["uid"], :name => "index_favicons_on_uid"

  create_table "invites", :force => true do |t|
    t.string   "code"
    t.integer  "max_count",   :default => 1
    t.integer  "users_count", :default => 0
    t.datetime "expire_date"
  end

  add_index "invites", ["code"], :name => "index_invites_on_code"

  create_table "links", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "url"
    t.string   "original_url"
    t.string   "uid"
    t.string   "uid_with_subdomain"
    t.string   "canonical"
    t.integer  "clicks_count",       :default => 0
    t.string   "title"
    t.string   "author"
    t.text     "description"
    t.text     "lede"
    t.text     "cached_keywords"
    t.text     "cached_links"
    t.string   "feed"
    t.datetime "date_posted"
    t.boolean  "has_favicon",        :default => false
    t.integer  "page_id"
    t.string   "html_title"
    t.text     "lookup_urls"
  end

  add_index "links", ["date_posted"], :name => "index_links_on_date_posted"
  add_index "links", ["uid_with_subdomain"], :name => "index_links_on_root_canonical"

  create_table "pages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "html"
    t.text     "url"
    t.integer  "code"
    t.boolean  "success",    :default => false
  end

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
    t.integer  "tools_count",                                                    :default => 0
    t.text     "cached_tools"
    t.string   "uid"
    t.integer  "bookmarks_count",                                                :default => 0
    t.text     "cached_bookmarks"
    t.string   "display_location"
    t.string   "location"
    t.decimal  "lat",                            :precision => 15, :scale => 10
    t.decimal  "lng",                            :precision => 15, :scale => 10
    t.integer  "jobs_count",                                                     :default => 0
    t.boolean  "has_favicon",                                                    :default => false
    t.integer  "link_id"
    t.boolean  "featured",                                                       :default => false
  end

  add_index "sites", ["alexa_global_rank"], :name => "index_sites_on_alexa_global_rank"
  add_index "sites", ["cached_slug"], :name => "index_sites_on_cached_slug", :unique => true
  add_index "sites", ["featured"], :name => "index_sites_on_featured"
  add_index "sites", ["google_pagerank"], :name => "index_sites_on_google_pagerank"
  add_index "sites", ["jobs_count"], :name => "index_sites_on_jobs_count"
  add_index "sites", ["lat", "lng"], :name => "index_sites_on_lat_and_lng"
  add_index "sites", ["link_id"], :name => "index_sites_on_link_id"
  add_index "sites", ["title"], :name => "index_sites_on_title"
  add_index "sites", ["tools_count"], :name => "index_sites_on_tools_count"

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "sources", :force => true do |t|
    t.datetime "created_at"
    t.string   "title"
    t.integer  "sourceable_id"
    t.string   "sourceable_type"
    t.integer  "link_id"
  end

  add_index "sources", ["sourceable_id", "sourceable_type"], :name => "index_sources_on_sourceable_id_and_sourceable_type"

  create_table "subscriptions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "referrer"
  end

  create_table "tools", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.string   "name"
    t.string   "url"
    t.text     "description"
    t.integer  "sites_count",       :default => 0
    t.integer  "language_id"
    t.text     "cached_sites"
    t.text     "cached_categories"
    t.string   "cached_language"
    t.integer  "bookmarks_count",   :default => 0
    t.text     "cached_bookmarks"
    t.integer  "jobs_count",        :default => 0
    t.string   "keyword"
    t.boolean  "has_favicon",       :default => false
    t.string   "uid"
    t.integer  "link_id"
    t.boolean  "featured",          :default => false
  end

  add_index "tools", ["cached_slug"], :name => "index_tools_on_cached_slug", :unique => true
  add_index "tools", ["featured"], :name => "index_tools_on_featured"
  add_index "tools", ["jobs_count"], :name => "index_tools_on_jobs_count"
  add_index "tools", ["link_id"], :name => "index_tools_on_link_id"
  add_index "tools", ["name"], :name => "index_tools_on_name"
  add_index "tools", ["sites_count"], :name => "index_tools_on_sites_count"

  create_table "usables", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "usable_id"
    t.integer  "tool_id"
    t.integer  "user_id"
    t.text     "description"
    t.integer  "importance_id"
    t.string   "usable_type"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "email",                                              :null => false
    t.string   "encrypted_password",   :limit => 128,                :null => false
    t.string   "password_salt",                                      :null => false
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
    t.string   "invite_code"
    t.text     "cached_site_claims"
    t.text     "cached_tool_claims"
    t.string   "time_zone"
    t.integer  "bookmarks_count",                     :default => 0
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
    t.integer  "site_id",                         :null => false
    t.integer  "user_id"
    t.text     "cached_bookmarks"
    t.integer  "bookmarks_count",  :default => 0
  end

  add_index "usings", ["site_id", "tool_id"], :name => "index_usings_on_site_id_and_tool_id"
  add_index "usings", ["site_id", "user_id"], :name => "index_usings_on_site_id_and_user_id"
  add_index "usings", ["site_id"], :name => "index_usings_on_site_id"
  add_index "usings", ["tool_id"], :name => "index_usings_on_tool_id"

end
