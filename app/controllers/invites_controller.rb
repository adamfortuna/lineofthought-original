class InvitesController < ApplicationController
  before_filter :authenticate_user!, :only => :index
  before_filter :require_admin!, :only => :create

  # GET /invites
  def index
    @user = current_user
    @invites = @user.invites.includes(:redeemers).order(:users_count)
    @reedeemed_count = @invites.redeemed.count
    @active_count = @invites.active.count
  end
  
  # POST /invites
  def create
    subscription = Subscription.find(params[:id])
    subscription.send_invite!(current_user)
    redirect_to subscriptions_path, :flash => { :notice => "Invitation sent to #{subscription.email}." }
  end
end