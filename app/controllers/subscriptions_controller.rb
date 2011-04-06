class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, :only => :index
  before_filter :require_admin!, :only => :index

  def index
    @user = current_user
    @subscriptions = Subscription.all.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
  end

  def new
    @subscription = Subscription.new
  end

  def create
    @subscription = Subscription.create(params[:subscription])
    if @subscription.new_record?
      flash[:error] = "There was a problem subscribing."
      render :new
    else
      render
    end
  end
end