class HomeController < ApplicationController
  before_filter :beta_user_check, :except => [:index]
  layout lambda { |res| ["index","subscribed"].include?(params[:action]) ? "notify" : "application" }
  caches_action :index, :beta, :style, :expires_in => 15.minutes

  
  def index; end
  def beta
    # @popular_sites = Site.order("alexa_global_rank").limit(5)
    @tools = Tool.order('sites_count desc').limit(5)
    @sites = Site.popular(5).with_tools(1)
  end
  def style; end
  def subscribed; end
end