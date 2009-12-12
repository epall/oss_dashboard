class AddEtagAndLastModifiedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :etag, :string
    add_column :projects, :last_modified, :datetime
  end

  def self.down
    remove_column :projects, :etag
    remove_column :projects, :last_modified
  end
end
