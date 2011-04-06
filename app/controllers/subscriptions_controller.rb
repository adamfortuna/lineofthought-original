class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!, :only => :index
  before_filter :require_admin!, :only => :index

  def index
    @user = current_user
    @subscriptions = Subscription.order(:invite_sent_at)
                                 .paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 25)
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
      redirect_to new_subscription_path, :flash => { :notice => "Thanks! We'll let you know as soon as we launch or have more spots open." }
    end
  end
end