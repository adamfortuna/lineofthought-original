class RegistrationsController < Devise::RegistrationsController
  ssl_required :new, :create

  def new
    @user = User.new
    @user.apply_omniauth(session[:omniauth])
  end

  def create
    super
    session[:omniauth] = nil unless @user.new_record?
  end
    

  def after_sign_up_path_for(resource)
    welcome_url
  end
  
  def after_inactive_sign_up_path_for(resource)
    welcome_url
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