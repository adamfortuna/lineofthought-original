class HomeController < ApplicationController
  # caches_action :index, :cache_path => Proc.new { |controller| controller.params.merge(:logged_in => logged_in? ) }, :expires_in => 15.minutes, :layout => false
  caches_action :index, :expires_in => 15.minutes, :layout => false

  # GET /
  def index
    @sites = Site.featured.order("updated_at desc").limit(10)
  end

  # GET /tellme
  def tellme; end

  # GET /subscribed
  def subscribed; end

  # GET /stream
  def stream; end
end