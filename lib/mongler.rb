require 'nokogiri'

class InvalidURL < StandardError
end

class Mongler
  def initialize(url)#,prefix=nil)
    url = "http://#{url}" if !is_url?(url)
    raise InvaildURL if !is_url?(url)
    @url = URI.parse(url)
    #@prefix = prefix
    open(url, "User-Agent" => "Mongler Ruby/#{RUBY_VERSION}") do |f|
      @content_type = f.content_type
      @charset = f.charset
      @raw_page = f.read
    end
    begin
      @doc = Nokogiri(@raw_page)
      @html = true
    rescue StandardError #make sure it doesn't catch SIGTERM and such.
      #assume the document is not html
      @html = false
    end
  end
  
  attr_reader :content_type,:charset

  def proxy_uri(page)
    full_goto_url = @url.merge(page)
    prox_uri = URI("/proxy")
    prox_uri.query = URI.encode_www_form("url" => full_goto_url.to_s)
    return prox_uri
  end

  def proxy_url(page)
    proxy_uri(page).to_s
  end

  def is_url?(url=nil)
    url.nil? ? !@url.scheme.nil? : !(URI.parse(url).scheme.nil?)
  end

  def mangle(tag, attribute)
    @doc.css(tag).each{|e| e[attribute] = proxy_url(e[attribute]) if !self.is_url?(e[attribute])} if @html
  end

  def parse
    @html ? @doc.to_s : @raw_page
  end
end
