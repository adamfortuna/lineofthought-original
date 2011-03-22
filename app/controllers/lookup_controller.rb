class LookupController < ApplicationController
  respond_to :html

  def new
    @url = params[:url]
    redirect_to sites_path(:format => params[:format]) unless @url
    
    handy_url = HandyUrl.new(@url)
    @link = Link.find(:first, :conditions => ["root_canonical = ? OR canonical = ?", handy_url.root_canonical, handy_url.canonical])
  
    # Found exact match for this site
    if @link && @link.site.nil? && @link.tool
      redirect_to tool_path(@link.tool, :format => params[:format])
    # Found exact match for this tool
    elsif @link && @link.tool.nil? && @link.site
      redirect_to site_path(@link.site, :format => params[:format])
    # Found both a site and a tool, show both options
    elsif @link && @link.tool && @link.site
      @tools = [@link.tool]
      @sites = [@link.site]
      respond_with(@link, @tools, @sites)
    # No exact match found, look for similar matches
    elsif @link.nil?
      links = Link.where(["uid = ?", handy_url.uid])
      @sites = []
      @tools = []
      links.each do |link|
        @sites << link.site if link.site
        @tools << link.tool if link.tool
      end
      @sites.uniq!
      @tools.uniq!

      @link = Link.new(:url => @url)
      respond_with(@link, @sites, @tools)
    end
  end
end