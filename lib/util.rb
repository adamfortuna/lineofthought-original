module Util
  def self.time_ceil_to_nearest_hour(time)
    Time.at((time.utc.to_i / 3600.0).ceil * 3600)
  end

  EMAIL             = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  USERNAME          = /\A\w[\w\.+\-_ ]+\Z/
  URL               = /^https?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  if Rails.env == "development"
    URL_HTTP_OPTIONAL = /^(?#Protocol)(?:http(?:s?)\:\/\/|~\/|\/)?(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:local|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}|0))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=;]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$/
  else
    URL_HTTP_OPTIONAL = /^(?#Protocol)(?:http(?:s?)\:\/\/|~\/|\/)?(?#Username:Password)(?:\w+:\w+@)?(?#Subdomains)(?:(?:[-\w]+\.)+(?#TopLevel Domains)(?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|[a-z]{2}|0))(?#Port)(?::[\d]{1,5})?(?#Directories)(?:(?:(?:\/(?:[-\w~!$+|.,=;]|%[a-f\d]{2})+)+|\/)+|\?|#)?(?#Query)(?:(?:\?(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)(?:&(?:[-\w~!$+|.,*:]|%[a-f\d{2}])+=?(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)*)*(?#Anchor)(?:#(?:[-\w~!$+|.,*:=]|%[a-f\d]{2})*)?$/
  end

  ##
  # Cleans up user-submitted URLs.  Adds http:// if it's missing, and strips
  # off any whitespace.
  # 
  # @param [String] url
  # @return [String]
  # 
  def self.normalize_url(url)
    return if url.blank?
    normalized = url.to_s.strip
    normalized = "http://#{normalized}" unless normalized =~ /\Ahttps?:\/\//i
    normalized
  end

  def self.parse_uri(url)
    return if url.blank?
    uri = if url.is_a?(URI)
            url
          else
            url = normalize_url(url.to_s)
            URI.parse(url)
          end
    uri.normalize!
    uri.scheme = uri.scheme.downcase # sub "http" for "HTTP"
    uri
  end
  
  def self.relative_url?(url)
    return if url.blank?
    uri = url.is_a?(URI) ? url : URI.parse(url)
    uri.relative?
  rescue
    false
  end  
end