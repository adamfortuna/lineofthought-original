module TemplateHelper
  def show_breadcrumbs(crumbs)
    "<p class='breadcrumbs'>#{crumbs}</p>"
  end
  
  def global_alexa_rank(rank)
    "Alexa Rank: #{number_with_delimiter(rank)}"
  end
  
  def google_pagerank(rank)
    "Google Pagerank: #{rank}"
  end
end