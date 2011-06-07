class RemoveBookmarkAnnotations < ActiveRecord::Migration
  def self.up
    drop_table :bookmark_annotations
  end

  def self.down
    create_table "bookmark_annotations", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "annotateable_type"
      t.integer  "annotateable_id"
      t.integer  "bookmark_id"
      t.text     "description"
    end
  end
end
