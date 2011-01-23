class Invite < ActiveRecord::Base
  def max_allowed?
    users_count >= max_count
  end
  def expired?
    !expire_date.nil? && (expire_date < Time.now)
  end
end