class SearchController < ApplicationController
  respond_to :html, :xml, :json

  def index
    Timeout::timeout(3) do
      @search = params[:search]
      search = Sunspot.search(Site, Tool) do
        keywords params[:search] if params[:search]
        paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 20)
      end
      @results = search.results
      @hits = search.hits
      respond_with(@results, @hits)
    end
  rescue Errno::ECONNREFUSED
    redirect_to root_path, :flash => { :error => "Sorry, search is currently unavailable." }
  end  
end