class Search
  extend ActiveSupport::Memoizable
  attr_accessor :search
  
  def results(options={})
    execute(options).results
  end
  
  def hits(options={})
    execute(options).hits
  end
  
  private
  def initialize(q)
    self.search = q
  end
  
  def execute(options={})
    Sunspot.search(Tool, Site) do
      any_of do
        with(:lower_name).starting_with(search.downcase)
        with(:lower_title).starting_with(search.downcase)
        with(:url, search)
      end
      keywords search
      paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
    end
  end
  memoize :execute
end