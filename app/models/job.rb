class Job < ActiveRecord::Base
  validates_presence_of :title, :url

end