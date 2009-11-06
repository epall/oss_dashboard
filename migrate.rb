require 'yaml'
require 'feed_detector'

Project.destroy_all

projects = YAML.load(File.read('projects.yml'))

projects.each do |old_project|
  new_project = Project.new
  new_project.name = old_project['Project Name']
  puts "Migrating #{new_project.name}"
  new_project.blog = old_project['Blog']
  new_project.wiki = old_project['Wiki']
  new_project.source_code = old_project['Source Code']
  new_project.website = old_project['Website']
  new_project.contributors = old_project['Contributors'].join(',')

  unless new_project.name == 'Fedora Kontributor'
    begin
      new_project.blog_feed = FeedDetector.fetch_feed_url(new_project.blog)
      new_project.source_code_feed = FeedDetector.fetch_feed_url(old_project['Repo']['URL']) if old_project['Repo']
    rescue URI::InvalidURIError => e
      puts "feed migration failed"
    end
  end

  new_project.save!
end
