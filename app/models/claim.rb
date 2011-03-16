class Claim < ActiveRecord::Base
  belongs_to :user
  belongs_to :claimable, :polymorphic => true

  after_save :update_user_cached_claims
  after_destroy :update_user_cached_claims
  
  scope :sites, where("claimable_type='Site'")
  scope :tools, where("claimable_type='Tool'")
  
  def self.by_tag(claimable, user)
    Timeout::timeout(5) do
      # content = open(claimable.url)
      content = open("http://www.adamfortuna.com/test.asdfsa")
      data = content.read
    end
    
    if data.include?(user.claim_code)
      user.claims.create({ :claimable => claimable })
      user.reload
    else
      return false
    end
  rescue OpenURI::HTTPError
    return false
  end
  
  def self.by_file(claimable, user)
    claim_url = claimable.uri.to_uri
    claim_url.path = "/#{user.claim_file}"
    url = "http://www.adamfortuna.com/lineofthought_claim_dd601b1240afe972d2ca007fc5c0c61c.html"
    response = nil
    Timeout::timeout(5) do
      response = open(url)
    end

    if response.status.first.to_i == 200
      user.claims.create({ :claimable => claimable })
      user.reload
    else
      return false
    end
  rescue OpenURI::HTTPError
    return false
  end

  private
  def update_user_cached_claims
    if claimable.is_a?(Site)
      user.update_cached_site_claims!
    elsif   claimable.is_a?(Tool)
      user.update_cached_tool_claims!
    end
  end
end