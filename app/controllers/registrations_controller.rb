class RegistrationsController < Devise::RegistrationsController
  before_filter :beta_user_check, :except => [:create, :new]
  layout nil

  def  new; end
  def create
    super
    session[:omniauth] = nil unless @user.new_record?
    redirect_to beta_path
  end
  
  private
  
  def build_resource(*args)
    super
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
    end
  end
end