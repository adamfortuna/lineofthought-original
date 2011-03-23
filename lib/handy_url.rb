class HandyUrl
  def ==(other)
    return true if super                # same object
    return true if @uri == other.to_uri # same URI (cheaper test)
    variants.any? { |v| v.to_uri == other.to_uri }
  end

  def blank?
    @original.blank?
  end

  def domainatrix
    @domainatrix ||= Domainatrix.parse(@uri.to_s)  if valid?
  end

  def root_domainatrix
    @root_domainatrix ||= Domainatrix.parse("#{domainatrix.scheme}://#{domainatrix.host}")
  end

  def canonical
    domainatrix.canonical
  end
  
  def host
    @uri.host if valid?
  end

  def path
    @uri.path if valid?
  end

  def port
    @uri.port if valid?
  end

  def scheme
    @uri.scheme if valid?
  end
  
  def query
    @uri.query if valid?    
  end

  def to_s
    valid? ? @uri.to_s : @original.to_s
  end

  def to_uri
    @uri
  end

  def valid?
    @valid
  end
  
  def domain
    domainatrix.domain.blank? ? nil : domainatrix.domain
  end
  
  def subdomain
    domainatrix.subdomain.blank? ? nil : domainatrix.subdomain
  end
  
  def domain_with_tld
    [domain, tld].join(".")
  end

  def tld
    domainatrix.public_suffix.blank? ? nil : domainatrix.public_suffix
  end
  
  def uid
    [tld, domain].compact.join(".")
  end
  
  def uid_with_subdomain
    sub = (subdomain == "www") ? nil : subdomain
    [tld, domain, sub].compact.join(".").downcase
  end
  
  def full_uid
    new_tld = ["com", "net", "org"].include?(tld) ? nil : tld
    sub = (subdomain == "www") ? nil : subdomain
    [sub, [domain, new_tld].compact.join("")].compact.join("-").downcase
  end
    
  def root_url_with_subdomain
    return nil unless valid?
    HandyUrl.new("#{scheme}://#{host}/")
  end
    
    
  ##
  # Checks to see if another HandyUrl exists on this Url.
  # Can be used to check if a specific page exists on a site.
  #
  # @returns boolean
  #
  def include?(other)
    return false unless valid? && other.valid?
    self == other.without_params(self.path)
  end

  ##
  # Returns an array of possible variations on this URL (with "www." in the
  # host, with "https", etc.).
  # 
  # @return [Array<HandyUrl>]
  # 
  def variants
    [with_www, without_www].compact.collect do |uri|
      [uri.with_http, uri.with_https]
    end.flatten
  end

  ##
  # Returns a variant of this URL with an http:// scheme.  If this URL is
  # already using the http:// scheme, this method returns self.
  # 
  # @return [HandyUrl, nil]
  # 
  def with_http
    return unless valid?
    return self if @uri.scheme == 'http'
    transform { |uri| uri.scheme = 'http' }
  end

  ##
  # Returns a variant of this URL with an https:// scheme.  If this URL is
  # already using the https:// scheme, this method returns self.
  # 
  # @return [HandyUrl, nil]
  # 
  def with_https
    return unless valid?
    return self if @uri.scheme == 'https'
    transform { |uri| uri.scheme = 'https' }
  end

  ##
  # Returns a variant of this URL with a leading "www." in the host name.  If
  # this URL's host already begins with "www.", this method returns self.
  # 
  # @return [HandyUrl, nil]
  # 
  def with_www
    return unless valid?
    return if host_is_ip_address?
    return self if @uri.host =~ /\Awww\./
    transform { |uri| uri.host = "www.#{uri.host}" }
  end


  ##
  # Returns a variant of this URL with any leading "www." in the host name
  # stripped out.  If this URL's host doesn't begin with "www.", this method
  # returns self.
  # 
  # @return [HandyUrl, nil]
  # 
  def without_www
    return unless valid?
    return self if @uri.host !~ /\Awww\./
    transform { |uri| uri.host = uri.host.sub(/\Awww\./, '') }
  end

  ##
  # Returns a variant of this URL without query params and with 
  # 
  # @return [HandyUrl, nil]
  #
  def without_params(comparison_path = nil)
    return unless valid?
    transform do |uri|
      uri.query = nil                                                                       # Dump all query parameters
      uri.path  = comparison_path if comparison_path && uri.path =~ /^#{comparison_path}/   # Only include the part of the path that matches the comparison URLs
    end
  end

  private

  def initialize(uri)
    if uri.is_a?(URI)
      @original = uri.to_s
      @uri      = uri
      @valid    = true
    else
      begin
        @uri      = parse_url(uri)
        @original = @uri.to_s
        @valid    = true
      rescue URI::InvalidURIError
        @original = uri
        @uri      = nil
        @valid    = false
      end
    end
  end

  ##
  # Convert a String into a (normalized) URI.
  # 
  # @param [String] url
  # @return [URI::HTTP]
  # 
  # @api private
  def parse_url(url)
    parsed_url = Util.parse_uri(Util.normalize_url(url))
    raise URI::InvalidURIError if parsed_url.nil?
    return parsed_url
  end

  def host_is_ip_address?
    valid? && @uri.host =~ /\A\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\Z/
  end

  def transform
    uri = @uri.dup
    yield uri
    self.class.new(uri.to_s)
  end
end
