class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.string :blog
      t.string :blog_feed
      t.string :source_code
      t.string :source_code_feed
      t.string :wiki
      t.string :password
      t.boolean :approved
      t.string :website
      t.string :contributors

      t.timestamps
    end
  end

  def self.down
    drop_table :projects
  end
end
