class HomeController < ApplicationController
  layout lambda { |res| ["index","subscribed"].include?(params[:action]) ? "notify" : "application" }
  caches_action :index, :expires_in => 15.minutes
  caches_action :style, :expires_in => 15.minutes

  
  def index; end
  def beta
    @tools = Tool.order('sites_count desc').limit(10)
    @sites = Site.order('alexa_global_rank').where(["tools_count > ? AND alexa_global_rank IS NOT NULL AND description IS NOT NULL and description != ''", 5]).limit(5)
  end
  def style; end
  def subscribed; end
end