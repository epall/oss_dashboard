class AddPersonalBlogToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :personal_blog_id, :integer
  end

  def self.down
    remove_column :events, :personal_blog_id
  end
end
