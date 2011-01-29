class HomeController < ApplicationController
  before_filter :beta_user_check, :except => [:index]
  layout lambda { |res| ["index","subscribed"].include?(params[:action]) ? "notify" : "application" }
  caches_action :index, :beta, :style
  
  def index; end
  def beta; end
  def style; end
  def subscribed; end
end