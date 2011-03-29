class DropJobsForNow < ActiveRecord::Migration
  def self.up
    drop_table :jobs
    drop_table :workables
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
    drop_table :importances
    drop_table :emails
    drop_table :articles
    drop_table :owners
  end

  def self.down
    create_table "importances", :force => true do |t|
      t.string "importance"
    end
    create_table "jobs", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "status"
      t.string   "title"
      t.string   "url"
      t.string   "company"
      t.text     "description"
      t.text     "how_to_apply"
      t.text     "cached_sites"
      t.text     "cached_tools"
      t.datetime "posted_at"
      t.string   "logo"
      t.string   "display_location"
      t.string   "location"
      t.string   "lat"
      t.string   "decimal"
      t.string   "lng"
      t.integer  "views_count"
    end
    create_table "workables", :force => true do |t|
      t.integer "job_id"
      t.string  "workable_type"
      t.string  "workable_id"
      t.text    "description"
    end

    add_index "workables", ["job_id"], :name => "index_workables_on_job_id"
    
    create_table "open_id_authentication_associations", :force => true do |t|
      t.integer "issued"
      t.integer "lifetime"
      t.string  "handle"
      t.string  "assoc_type"
      t.binary  "server_url"
      t.binary  "secret"
    end

    create_table "open_id_authentication_nonces", :force => true do |t|
      t.integer "timestamp",  :null => false
      t.string  "server_url"
      t.string  "salt",       :null => false
    end

    create_table "emails", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
      t.string   "email"
      t.string   "name"
      t.string   "claim_code"
      t.boolean  "confirmed",  :default => false
    end

    create_table "articles", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "title"
      t.text     "url"
      t.text     "description"
      t.text     "cached_tools"
      t.text     "cached_sites"
      t.text     "cached_connections"
      t.string   "cached_slug"
      t.boolean  "has_favicon",        :default => false
    end

    add_index "articles", ["cached_slug"], :name => "index_articles_on_cached_slug"
    add_index "articles", ["created_at"], :name => "index_articles_on_created_at"
    
  end
end
