class User < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :token_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :username, :password, :password_confirmation, :remember_me, :invite_code, :time_zone, :url, :description
  attr_protected  :lines_count, :claimed_sites_count, :claimed_tools_count

  has_many :claims
  has_many :sites, :through => :claims, :source => :site,
                   :conditions => "claims.claimable_type = 'Site'"
  has_many :tools, :through => :claims, :source => :tool,
                   :conditions => "claims.claimable_type = 'Tool'"
  has_many :authentications
  has_many :bookmarks, :class_name => "BookmarkUser"
  has_many :usings
  
  validate :validate_invite, :on => :create
  after_create :increment_invite, :if => :invite_code?
  serialize :cached_site_claims
  serialize :cached_tool_claims

  validates_presence_of :username
  validates_uniqueness_of :username
  validates_length_of :username, :in => 1..25
  validates_format_of :username, :with => /^[\w\d_]+$/, :message => "is invalid. Please use only letters, number and underscores."
  
  validates_format_of :url, :with => Util::URL_HTTP_OPTIONAL, :message => "Must be a valid URL.", :allow_blank => true


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
    site_id = object.is_a?(Site) ? object.id : object
    cached_site_claims.include?(site_id)
  end

  def claimed_tool?(object)
    return false if cached_tool_claims.nil? || cached_tool_claims.empty?
    tool_id = object.is_a?(Tool) ? object.id : object
    cached_tool_claims.include?(tool_id)
  end
  
  def find_or_create_claim(object, method)
    claim = self.claims.find(:first, 
                             :conditions => ["claimable_type = ? AND claimable_id = ?", object.class.to_s, object.id])
    claim = self.claims.create({:claimable => object, :claim_method => method}) if claim.nil?

    if claim && claim.claim_method != method
      claim.update_attribute(:claim_method, method)
    end
    return claim
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
  memoize :admin?

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
  
  # Add new usings to a site
  def can_add_lines?(object)
    return true if admin? || super_editor?
    if object.is_a?(Site)
      return true if !object.locked?
      return cached_site_claims && cached_site_claims.include?(object.id)
    elsif object.is_a?(Tool)
      return true
      # return cached_tool_claims && cached_tool_claims.include?(object.id)
    end
  end

  # Edit an existing using
  def can_edit_using?(using, site = nil, tool = nil)
    return true if admin? || super_editor?
    return true if using.user_id == self.id
    site = site || using.site
    return can_edit_site?(site) if site
    tool = tool || using.tool
    return can_edit_tool?(tool) if tool
    return false
  end

  # Remove an existing using
  def can_destroy_using?(using, site = nil, tool = nil)
    return true if admin? || super_editor?
    return true if using.user_id == self.id    
    site = site || using.site
    return can_edit_site?(site) if site
    tool = tool || using.tool
    return can_edit_tool?(tool) if tool
    return false
  end
  
  # Returns a Gravatar URL associated with the email parameter.
  def gravatar_url(gravatar_options={})

    # Default highest rating.
    # Rating can be one of G, PG, R X.
    # If set to nil, the Gravatar default of X will be used.
    gravatar_options[:rating] ||= nil

    # Default size of the image.
    # If set to nil, the Gravatar default size of 80px will be used.
    gravatar_options[:size] ||= nil 

    # Default image url to be used when no gravatar is found
    # or when an image exceeds the rating parameter.
    gravatar_options[:default] ||= nil

    # Build the Gravatar url.
    grav_url = 'http://www.gravatar.com/avatar.php?'
    grav_url << "gravatar_id=#{Digest::MD5.new.update(email)}" 
    grav_url << "&rating=#{gravatar_options[:rating]}" if gravatar_options[:rating]
    grav_url << "&size=#{gravatar_options[:size]}" if gravatar_options[:size]
    grav_url << "&default=#{gravatar_options[:default]}" if gravatar_options[:default]
    return grav_url
  end
  
  def karma
    lines_count + (claimed_sites_count * 20) + (claimed_tools_count * 5)
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