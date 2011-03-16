class RegistrationsController < Devise::RegistrationsController
  def new; end
  def create
    super
    session[:omniauth] = nil unless @user.new_record?
    redirect_to beta_path if user_signed_in?
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