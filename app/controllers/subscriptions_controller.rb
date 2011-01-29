class SubscriptionsController < ApplicationController
  layout 'notify'

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