# Redirect all ActiveRecord logging to +stream+.
#
# Example:
#   log_to(STDOUT)
#
# will redirect all ActiveRecord logging to the console
def log_to(stream = STDOUT)
  logger = Logger.new(stream)
  ActiveRecord::Base.clear_all_connections!
  
  [ActiveRecord::Base, ActiveResource::Base].each {|mod| mod.logger = logger }
end
