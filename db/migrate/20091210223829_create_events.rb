class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :project_id
      t.string :type
      t.string :identifier
      t.string :title
      t.string :permalink
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
