Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'wUrNLQeBK7vMt6ScrZTZQ', 'L3TknnzswqAyxYXU2KtjspC0qKaUFcHWuUCrWS4rr0'
  provider :facebook, '161850477205988', '2dc63abe7b753fbc2e9a3384d0b04311', :scope => 'email,user_hometown,user_website,user_about_me' 
end