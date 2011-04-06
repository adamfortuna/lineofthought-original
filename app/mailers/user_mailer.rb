class UserMailer < ActionMailer::Base
  default :from => "Line Of Thought <support@lineofthought.com>"
  
  def invite_from_subscription(subscription)
    @subscription = subscription
    mail(:to => subscription.email, :subject => "Invitation to join Line of Thought")
  end
end
