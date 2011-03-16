class Source < ActiveRecord::Base
  belongs_to :link
  belongs_to :sourceable, :polymorphic => true
  validates_presence_of :title

  private
  
  before_validation :set_popular_title, :on => :create
  def set_popular_title
    self.title = link.title
  end
end