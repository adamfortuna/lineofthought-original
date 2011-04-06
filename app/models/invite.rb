class Invite < ActiveRecord::Base
  belongs_to :user
  has_many :redeemers, :class_name => 'User', :foreign_key => :invite_code, :primary_key => :code
  validates_uniqueness_of :code, :on => :create, :message => "must be unique"

  scope :redeemed, where("max_count <= users_count")
  scope :active, where("max_count > users_count")

  def self.generate_for_user!(user, count=1)
    transaction do
      count.times do
        created = false
        while !created
          invite = Invite.create({:code => ActiveSupport::SecureRandom.hex(4), :user => user })
          created = true if !invite.new_record?
        end
      end
    end
  end
  
  def max_allowed?
    users_count >= max_count
  end
  def expired?
    !expire_date.nil? && (expire_date < Time.now)
  end
end