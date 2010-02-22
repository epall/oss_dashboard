class AddPresentationCountToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :presentation_count, :integer, :default => 0
  end

  def self.down
    remove_column :projects, :presentation_count
  end
end
