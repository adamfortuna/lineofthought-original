class HomeController < ApplicationController
  before_filter :redirect_if_signed_in!, :only => :index
  layout lambda { |res| ["index","subscribed"].include?(params[:action]) ? "notify" : "application" }
  caches_action :index, :expires_in => 15.minutes
  caches_action :style, :expires_in => 15.minutes
  
  def index; end
  def beta
    @featured = Tool.featured.limit(5)
    @sites = Site.highlighted.limit(5)
  end
  def style; end
  def subscribed; end
  
  private 
  def redirect_if_signed_in!
    redirect_to beta_path if session_exists?
  end
end