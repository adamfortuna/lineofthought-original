class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, :only => :index
  before_filter :require_admin!, :only => :index
  layout lambda { |res| ["create"].include?(params[:action]) ? "notify" : "application" }

  def index
    @subscriptions = Subscription.all.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
  end

  def create
    @subscription = Subscription.create(params[:subscription])
    if @subscription.new_record?
      flash[:error] = "There was a problem subscribing."
      render "home/index"
    else
      render
    end
  end
end