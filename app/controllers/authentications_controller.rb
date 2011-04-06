class AuthenticationsController < ApplicationController  
  ssl_required :create
  before_filter :authenticate_user!, :only => [:index, :destroy]

  def index  
    @user = current_user
    @authentications = current_user.authentications if user_signed_in?
  end
  
  def failure
    if params[:message] == "invalid_credentials"
      flash[:error] = "For some reason we weren't able to verify your authentication with your provider. Please try again."
    end

    if logged_in? 
      redirect_to authentications_url
    else
      redirect_to new_user_registration_url
    end
  end

  # authentications_controller.rb
  def create
    puts "authentications#create"
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      puts "authentications#create - found"
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, authentication.user)
    elsif current_user
      puts "authentications#create - not found, but logged in, adding it"
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      # if user.save
      #   puts "authentications#create - user saved, redirecting to sign in"
      #   flash[:notice] = "Signed in successfully."
      #   sign_in_and_redirect(:user, user)
      # else
        puts "authentications#create - user not saved, new user!"
        email = omniauth['extra']['user_hash']['email'] rescue nil
        nickname = omniauth['user_info']['nickname'] rescue nil
        usable_omniauth =  {
          'uid' => omniauth['uid'],
          'provider' => omniauth['provider'],
          'extra' => { 'user_hash' => { 'email' =>  email } },
          'user_info' => { 'nickname' => nickname }
        }
        session[:omniauth] = usable_omniauth
        puts "authentications#create - user not saved, redirecting to signup form "
        redirect_to new_user_registration_url
      # end
    end
  end
      
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully destroyed authentication."
    redirect_to authentications_url
  end
end