class InvitesController < ApplicationController
  before_filter :authenticate_user!, :only => :index

  def index
    @user = current_user
    @invites = @user.invites.includes(:redeemers).order(:users_count)
    @reedeemed_count = @invites.redeemed.count
    @active_count = @invites.active.count
  end
end