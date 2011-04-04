class SiteClaimsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_record, :only => [:new, :create]
  respond_to :html

  # GET /sites/:site_id/claims/new
  def new; end

  # POST /sites/:site_id/claims
  # todo
  def create
    @claim = current_user.find_or_create_claim(@site, params[:using])
    
    # Retry verification
    if @claim && @claim.verification_failed? && @claim.status_updated_at < 30.seconds.ago.to_datetime
      @claim.retry!
      @claim.attempt_to_verify! 
    end

    respond_to do |format|
      format.js do
        if @claim.nil?
          render :create_failed
        elsif @claim.verified?
          flash[:notice] = "You have successfully claimed this site."
          render :create
        elsif @claim.verification_failed? 
          render :create_failed
        elsif @claim.unverified?
          render :js => "console.log('create in progress');"
        else # unknown error
          render :create_failed
        end
      end
    end
  end
  
  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
end