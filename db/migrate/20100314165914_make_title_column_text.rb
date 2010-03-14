class MakeTitleColumnText < ActiveRecord::Migration
  def self.up
    change_column :events, :title, :text
  end

  def self.down
    change_column :events, :title, :string
  end
end
