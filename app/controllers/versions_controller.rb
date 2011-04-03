class VersionsController < ApplicationController
  before_filter :authenticate_user!
  
  def revert
    @version = Version.find(params[:id])
    if @version.reify
      @version.reify.restore!
    else
      @version.item.destroy
    end
    redirect_to :back, :notice => "Successfully reverted to a previous version."
  end
end
