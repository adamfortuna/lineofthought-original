require 'timeout'
class Loader
  extend ActiveSupport::Memoizable
  
  attr_accessor :url, :timeout, :doc
  attr_accessor :title, :description, :lede, :keywords, :feed, :favicon, :datetime, :body

  def tools
    tool_keywords = @keywords.collect do |keyword|
      keyword[0] if known_tool_keywords.include?(keyword[0])
    end.compact
    return [] if tool_keywords.blank?
    Tool.where(["tools.keyword IN (?)", tool_keywords]).select("tools.name, tools.id, tools.cached_slug")
  end
  memoize :tools
  
  def categories
    category_keywords = @keywords.collect do |keyword|
      keyword[0] if known_category_keywords.include?(keyword[0])
    end.compact
    return [] if category_keywords.blank?
    Category.where(["categories.keyword IN (?)", category_keywords])
  end
  memoize :categories

  private
  def initialize(url, timeout = 5)
    @url = url
    @timeout = timeout
    @title = nil
    @description = nil
    parse
    true
  end

  def parse
    @doc = Pismo::Document.new(@url)
    @keywords = @doc.keywords
    @title = @doc.title
    @description = @doc.description
    @lede = @doc.lede
    @feed = @doc.feed
    @favicon = @doc.favicon
    @datetime = @doc.datetime
    @body = @doc.body
  end
  
  def known_tool_keywords
    Rails.cache.fetch("known_tool_keywords", :expires_in => 1.hour) do
      all_keywords = []
      Tool.find_in_batches(:conditions => "keyword IS NOT NULL", :select => :keyword) do |tools|
        tools.each do |tool|
          all_keywords << tool.keyword
        end
      end
      all_keywords
    end
  end
  memoize :known_tool_keywords
  
  def known_category_keywords
    Rails.cache.fetch("known_category_keywords", :expires_in => 1.hour) do
      all_keywords = []
      Category.find_in_batches(:conditions => "keyword IS NOT NULL", :select => :keyword) do |category|
        category.each do |category|
          all_keywords << category.keyword
        end
      end
      all_keywords
    end
  end
  memoize :known_category_keywords
end