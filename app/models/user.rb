class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :invite_code

  has_many :claims
  
  validate :validate_invite, :on => :create
  after_create :increment_invite, :if => :invite_code?
  serialize :cached_site_claims
  serialize :cached_tool_claims

  def claim_id
    "<meta name=\"lineofthought-claim\" content=\"#{claim_code}\" />"
  end

  def claim_file
    "lineofthought_claim_#{claim_code}.html"
  end
  
  def claim_code
    Digest::MD5.hexdigest("lineofthought-claim-#{self.id}-#{self.created_at}")
  end

  def update_cached_site_claims!
    cached_site_claims = []
    claims.includes(:claimable).each do |claim|
      cached_site_claims << claim.claimable.id
      cached_site_claims << claim.claimable.cached_slug
    end
    save
  end

  def update_cached_tool_claims!
    cached_tool_claims = []
    claims.includes(:claimable).each do |claim|
      cached_tool_claims << claim.claimable.id
      cached_tool_claims << claim.claimable.cached_slug
    end
    save
  end

  def claimed_site?(object)
    return false if cached_site_claims.nil? || cached_site_claims.empty?
    if object.is_a?(Site)
      cached_site_claims.include?(object.id)
    elsif
      cached_site_claims.include?(object)
    end
  end

  def claimed_tool?(object)
    return false if cached_tool_claims.nil? || cached_tool_claims.empty?
    if object.is_a?(Tool)
      cached_tool_claims.include?(object.id)
    elsif object_type == 'Tool'
      cached_tool_claims.include?(object)
    end
  end
  
  def admin?
    email.include?("@lineofthought.com")
  end

  private
  def validate_invite
    invite = Invite.find_by_code(self.invite_code)
    if !invite
      errors.add(:invite_code, "could not be found")
    elsif invite.max_allowed?
      errors.add(:invite_code, "has already been redeemed")
    elsif invite.expired?
      errors.add(:invite_code, "has expired")
    end
  end
  
  def increment_invite
    invite = Invite.find_by_code(self.invite_code)
    invite.increment! :users_count if invite
  end
end