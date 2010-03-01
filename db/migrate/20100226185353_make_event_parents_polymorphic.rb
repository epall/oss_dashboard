class MakeEventParentsPolymorphic < ActiveRecord::Migration
  def self.up
    add_column :events, :event_producer_id, :integer
    add_column :events, :event_producer_type, :string
    Event.all.each do |evt|
      evt.event_producer_id = evt.project_id || evt.personal_blog_id
      evt.event_producer_type = "Project" if evt.project_id
      evt.event_producer_type = "PersonalBlog" if evt.personal_blog_id
      evt.save!
    end
  end

  def self.down
    remove_column :events, :event_producer_id
    remove_column :events, :event_producer_type
  end
end
