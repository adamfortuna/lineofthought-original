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

  def self.parse_admin_uri(url)
    parse_uri(normalize_url(correct_admin_uri(url)))
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

  ## 
  # Remove WordPress admin URL extras from "Admin" URL
  # Just in case. ;)
  def self.correct_admin_uri(uri)
    url = uri.to_s
    if url =~ %r{wp-admin}
      url.gsub(/wp-admin.*$/, '')
    elsif url =~ %r{mt\.cgi}
      url.gsub(/mt\.cgi.*$/, '')
    elsif url =~ %r{mt\-xmlrpc\.cgi}
      url.gsub(/mt\-xmlrpc\.cgi.*$/, '')
    else
      url
    end
  end

  ##
  # Look up a country's name by its 2-letter ISO code (ie. "US" -> "United
  # States").
  # 
  # @param [String] alpha2
  #   2-letter country code (ie. "US")
  # @raise [I18n::ArgumentError]
  #   If no country name exists in the locale file.  Expected to be defined
  #   under countries.{alpha2}.
  # @return [String]
  #   Country name (ie. "United States").  Will be internationalized.
  # 
  def self.country_name_by_alpha2(alpha2)
    I18n.t("countries.#{alpha2.to_s.upcase}", :raise => true)
  end

  ##
  # Look up a country's 2-letter ISO code by its name (ie. "United States" ->
  # "US").  Expects the "countries" key in the locale file to define a Hash
  # with alpha codes as keys, and country names as values (ie. {"US" =>
  # "United States"}).  This method then inverts that hash to perform a lookup
  # by name rather than by code.
  # 
  # @param [String] name
  #   Country name (ie. "United States").
  # @raise [I18n::ArgumentError]
  #   If no country exists in the locale file.
  # @return [String]
  #   Country code (ie. "US").
  # 
  def self.country_alpha2_by_name(name)
    I18n.t('countries', :raise => true).invert.fetch(name).to_s
  end
end
