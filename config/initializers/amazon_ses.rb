ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => '096RRJ93PTDQPZZ44802',
  :secret_access_key => 'GXZ0vgPaG57k/vBEJFXyngpImh3yvziyWUfdXueJ'
  
  
# For console use:
# ses = AWS::SES::Base.new(
# :access_key_id     => '096RRJ93PTDQPZZ44802',
# :secret_access_key => 'GXZ0vgPaG57k/vBEJFXyngpImh3yvziyWUfdXueJ'  )