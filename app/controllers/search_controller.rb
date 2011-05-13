class SearchController < ApplicationController
  respond_to :html, :xml, :json

  def index
    raise Errno::ECONNREFUSED if !Settings.use_solr

    search = Search.new(params[:q])
    
    @results = search.results
    @hits = search.hits
    
    respond_to do |format|
      format.html { render }
      format.json { respond_with @results.collect(&:autocomplete_data) }
    end
  rescue Timeout::Error, Errno::ECONNREFUSED
    redirect_to root_path, :flash => { :error => "Sorry, search is currently unavailable." }
  end  
end