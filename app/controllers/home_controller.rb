class HomeController < ApplicationController
  # caches_action :index, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 15.minutes, :layout => false
  caches_action :index, :expires_in => 3.minutes, :layout => false
  caches_action :about, :expires_in => 30.minutes, :layout => false

  # GET /
  def index
    @sites = Site.order("created_at desc").where("tools_count > 3").limit(10)
  end

  # GET /about
  def about; end

  # GET /welcome
  def welcome; end

  # GET /stream
  def stream; end
  
  # GET /license
  def license; end
end