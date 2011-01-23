class SessionsController < Devise::SessionsController
  before_filter :beta_user_check, :except => [:create, :new, :destroy]
  layout nil
end