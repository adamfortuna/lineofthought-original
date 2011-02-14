module TemplateHelper
  def show_breadcrumbs(crumbs)
    "<p class='breadcrumbs'>#{crumbs}</p>"
  end
  
  def global_alexa_rank(rank)
    "<li class='alexa'><span><em>#{number_with_delimiter(rank)}</em>Alexa</span></li>"
  end
  
  def google_pagerank(rank)
    "<li class=\"pagerank pagerank-#{rank}\"><span><em>#{rank}</em>Pagerank</span></li>"
  end
  
  def menu_link(text, link, options = {})
    options.reverse_merge! :a_class => [], :li_class => []

    # If there is only one option passed in, convert it to an array
    options[:li_class] = Array.new([options[:li_class]]) if options[:li_class].class == String
    #options[:li_class].push("current") if current_page?(link)
    options[:li_class].push("current") if request.path_info == link
    
    content_tag :li, menu_a(text,link, options), :class => options[:li_class].length > 0 ? options[:li_class].join(' ') : nil
  end
  
  def menu_a(text, link, options = {})
    options[:a_class] = Array.new([options[:a_class]]) if options[:a_class].class == String
    link_to text, link, { :class => options[:a_class].length > 0 ? options[:a_class].join(' ') : nil }
  end  
end