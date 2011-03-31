class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation, :remember_me, :invite_code, :time_zone

  has_many :claims
  has_many :sites, :through => :claims, :source => :site,
                   :conditions => "claims.claimable_type = 'Site'"
  has_many :tools, :through => :claims, :source => :tool,
                   :conditions => "claims.claimable_type = 'Tool'"
  has_many :authentications
  has_many :bookmarks, :class_name => "BookmarkUser"
  
  validate :validate_invite, :on => :create
  after_create :increment_invite, :if => :invite_code?
  serialize :cached_site_claims
  serialize :cached_tool_claims

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 1..25


  def to_param
    self.username
  end

  def apply_omniauth(omniauth)
    self.email = omniauth['extra']['user_hash']['email'] if email.blank?
    self.username = omniauth['user_info']['nickname'] if username.blank?
    self.time_zone = ActiveSupport::TimeZone[-5] if time_zone.blank? # omniauth['extra']['user_hash']['timezone']
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  rescue
    nil
  end
  
  def auth_with_twitter?
    authentications.collect(&:provider).include?("twitter")
  end

  def auth_with_facebook?
    authentications.collect(&:provider).include?("facebook")
  end

  def authentication_services
    authentications.collect(&:provider).compact.uniq
  end
  memoize :authentication_services


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
    self.cached_site_claims = []
    claims.where("claimable_type='Site'").includes(:claimable).each do |claim|
      self.cached_site_claims << claim.claimable.id
      self.cached_site_claims << claim.claimable.cached_slug
    end
    save
  end

  def update_cached_tool_claims!
    self.cached_tool_claims = []
    claims.where("claimable_type='Tool'").includes(:claimable).each do |claim|
      self.cached_tool_claims << claim.claimable.id
      self.cached_tool_claims << claim.claimable.cached_slug
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

  # Is this users email confirmed?
  def confirmed?
    !confirmed_at.nil?
  end
  
  def contributor?
    true
  end
  
  def editor?
    false
  end

  def super_editor?
    false
  end
  
  def admin?
    email.include?("@lineofthought.com")
  end

  def can_edit_tool?(tool)
    admin? || editor? || claimed_tool?(tool)
  end

  def can_destroy_tool?(tool)
    admin?
  end

  def can_edit_site?(site)
    admin? || editor? || claimed_site?(site)
  end

  def can_destroy_site?(site)
    admin?
  end

  def can_edit_using?(using, site = nil, tool = nil)
    return using.user_id == self.id    
    return can_edit_site?(site) if site
    return can_edit_tool?(tool) if tool
    return false
  end

  def can_destroy_using?(using, site = nil, tool = nil)
    return using.user_id == self.id    
    return can_edit_site?(site) if site
    return can_edit_tool?(tool) if tool
    return false
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