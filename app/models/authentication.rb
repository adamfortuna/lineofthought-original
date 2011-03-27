class Authentication < ActiveRecord::Base
  belongs_to :user
  
  def provider_name
    provider.titleize
  end
end