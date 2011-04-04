class Claim < ActiveRecord::Base
  belongs_to :user
  belongs_to :claimable, :polymorphic => true

  belongs_to :site, :class_name => "Site", :foreign_key => "claimable_id"
  belongs_to :tool, :class_name => "Tool", :foreign_key => "claimable_id"
  
  validates_uniqueness_of :user_id, :scope => [:claimable_id, :claimable_type]
  
  scope :sites, where("claimable_type='Site'")
  scope :tools, where("claimable_type='Tool'")
  
  state_machine :status, :initial => :unverified do
    state :unverified do
    end

    state :verified do
    end

    state :verification_failed do
    end

    before_transition any => any, :do => :set_status_updated_at

    after_transition :to => :verified, :do => :update_user_cached_claims
    event :verify_claim do
      transition [:unverified, :verification_failed] => :verified, :if => :able_to_verify?
      transition [:unverified, :verification_failed] => :verification_failed
    end
    
    after_transition :on => :revoke, :do => :update_user_cached_claims
    event :revoke do
      transition :verified => :unverified
    end
    event :retry do
      transition :verification_failed => :unverified
    end
    event :bypass_and_claim do
      transition :unverified => :verified
    end
  end
  
  def self.by_tag(claimable, user)
    data = nil
    Timeout::timeout(5) do
      content = open(claimable.url)
      data = content.read
    end
    
    # Todo: make sure the code is in the head of the page.
    if data.include?(user.claim_code)
      user.claims.create({ :claimable => claimable })
      user.reload
      return true
    else
      return false
    end
  rescue OpenURI::HTTPError
    return false
  end
  
  def self.by_file(claimable, user)
    claim_url = claimable.uri.to_uri
    claim_url.path = "/#{user.claim_file}"
    response = nil
    Timeout::timeout(5) do
      response = open(claim_url.to_s)
    end

    if response.status.first.to_i == 200
      user.claims.create({ :claimable => claimable })
      user.reload
      return true
    else
      return false
    end
  rescue OpenURI::HTTPError
    return false
  end
  
  after_create :attempt_to_verify!
  def attempt_to_verify!
    self.verify_claim!
  end
  handle_asynchronously :attempt_to_verify!, :priority => -50
  

  private
  def update_user_cached_claims
    if claimable.is_a?(Site)
      user.update_cached_site_claims!
    elsif claimable.is_a?(Tool)
      user.update_cached_tool_claims!
    end
  end
  
  def able_to_verify?
    if claim_method == "file"
      return Claim.by_file(claimable, user)
    elsif claim_method == "tag"
      return Claim.by_tag(claimable, user)
    end
    return false
  end
  
  before_create :set_status_updated_at
  def set_status_updated_at
    self.status_updated_at = Time.now
  end
end