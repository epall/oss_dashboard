class CreatePersonalBlogs < ActiveRecord::Migration
  def self.up
    create_table :personal_blogs do |t|
      t.string :name
      t.string :weblink
      t.string :feed
      t.string :etag
      t.datetime :last_modified
      t.boolean :approved, :default => false
      t.integer :group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :personal_blogs
  end
end
