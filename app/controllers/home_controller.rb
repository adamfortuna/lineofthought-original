class HomeController < ApplicationController
  before_filter :redirect_if_signed_in!, :only => :index
  layout lambda { |res| ["index","subscribed"].include?(params[:action]) ? "notify" : "application" }
  caches_action :index, :expires_in => 15.minutes
  caches_action :beta, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 1.hour


  def index; end
  def beta
    @sites = Site.featured.limit(5)
  end
  def subscribed; end

  def fail
    Aasdfa
  end
  
  def stream; end

  private 
  def redirect_if_signed_in!
    redirect_to beta_path if user_signed_in?
  end
end