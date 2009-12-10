class Event < ActiveRecord::Base
  belongs_to :project
  
  def self.create_if_new(raw_article, type)
    # TODO
  end
end
