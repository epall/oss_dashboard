# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100322181548) do

  create_table "events", :force => true do |t|
    t.integer  "project_id"
    t.string   "entry_type"
    t.string   "identifier"
    t.text     "title",               :limit => 255
    t.string   "permalink"
    t.text     "content"
    t.text     "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "personal_blog_id"
    t.integer  "event_producer_id"
    t.string   "event_producer_type"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "admin_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mailing_list"
  end

  create_table "personal_blogs", :force => true do |t|
    t.string   "name"
    t.string   "weblink"
    t.string   "feed"
    t.string   "etag"
    t.datetime "last_modified"
    t.boolean  "approved",      :default => false
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "blog"
    t.string   "blog_feed"
    t.string   "source_code"
    t.string   "source_code_feed"
    t.string   "wiki"
    t.string   "password"
    t.boolean  "approved"
    t.string   "website"
    t.string   "contributors"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "blog_etag"
    t.datetime "blog_last_modified"
    t.string   "code_etag"
    t.datetime "code_last_modified"
    t.integer  "group_id"
    t.text     "description"
    t.integer  "presentation_count", :default => 0
    t.boolean  "sponsored"
  end

end
