class Source < ActiveRecord::Base
  validates_presence_of :url, :title
  belongs_to :sourceable, :polymorphic => true
end