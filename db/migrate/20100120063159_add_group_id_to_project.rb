class AddGroupIdToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :group_id, :integer
  end

  def self.down
    remove_column :projects, :group_id
  end
end
