require 'rspec'
require 'mocha'

Rspec.configure do |c|
  c.mock_with :mocha
end