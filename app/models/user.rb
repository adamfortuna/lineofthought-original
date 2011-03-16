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
    update_attribute(:cached_site_claims, claims.sites.select(:claimable_id).collect(&:claimable_id))
  end

  def update_cached_tool_claims!
    update_attribute(:cached_tool_claims, claims.tools.select(:claimable_id).collect(&:claimable_id))
  end

  def claimed?(object)
    if object.is_a?(Site)
      cached_site_claims && cached_site_claims.include?(object.id)
    elsif object.is_a?(Site)
      cached_tool_claims && cached_tool_claims.include?(object.id)
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