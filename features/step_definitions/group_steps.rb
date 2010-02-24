Given /a group called (.+)/ do |name|
  Group.create(:name => name)
end