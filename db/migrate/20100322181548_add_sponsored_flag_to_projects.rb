class AddSponsoredFlagToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :sponsored, :boolean
  end

  def self.down
    remove_column :projects, :sponsored
  end
end
