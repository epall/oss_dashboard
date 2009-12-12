class AddEtagAndLastModifiedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :blog_etag, :string
    add_column :projects, :blog_last_modified, :datetime
    add_column :projects, :code_etag, :string
    add_column :projects, :code_last_modified, :datetime
  end

  def self.down
    remove_column :projects, :blog_etag
    remove_column :projects, :blog_last_modified
    remove_column :projects, :code_etag
    remove_column :projects, :code_last_modified
  end
end
