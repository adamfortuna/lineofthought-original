class Subscription < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => Util::EMAIL
  validates_uniqueness_of :email, :message => "is already subscribed."
  belongs_to :invite
  
  def send_invite!(sender)
    transaction do
      self.invite = Invite.generate_for_user!(sender)
      self.invite_sent_at = Time.now
      UserMailer.invite_from_subscription(self).deliver
      self.save!
    end
  end
  
  def invited?
    !invite_id.nil?
  end
end