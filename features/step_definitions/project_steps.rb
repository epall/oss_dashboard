Given /a project called (.+)/ do |name|
  Project.create(:name => name, :group => Group.last, :contributors => '')
end