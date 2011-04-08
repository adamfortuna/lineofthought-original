Factory.sequence(:tool_url) { |n| "http://tool-#{n}.com" }
Factory.sequence(:tool_name) { |n| "Tool Name #{n}" }

# This will guess the User class
Factory.define :tool do |u|
  u.name { Factory.next(:tool_name) }
  u.url  { Factory.next(:tool_url) }
end