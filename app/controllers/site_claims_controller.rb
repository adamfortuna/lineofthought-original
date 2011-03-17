class SiteClaimsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_record, :only => [:new, :create]
  respond_to :html

  # GET /sites/:site_id/claims/new
  def new
    @articles = @site.articles.recent(5)
  end

  # POST /sites/:site_id/claims
  # todo
  def create
    fetch_method = params[:using]
    
    if fetch_method == "tag"
      Claim.by_tag(@site, current_user)
    else
      Claim.by_file(@site, current_user)
    end
    
    if current_user.claimed?(@site)
      redirect_to site_path(@site), :notice => "You've now claimed this site! You can now fully edit it's contents."
    else
      flash[:error] = "We weren't able to verify your claim, please try again."
      render :new
    end
  end
  
  private
  def load_record
    @site = Site.find_by_cached_slug(params[:site_id])
  end
end