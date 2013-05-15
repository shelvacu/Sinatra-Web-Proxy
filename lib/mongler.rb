require 'nokogiri'

class InvalidURL < StandardError
end

class Mongler
  def initialize(url,page_params)#,prefix=nil)
    url = "http://#{url}" if !is_url?(url)
    raise InvaildURL if !is_url?(url)
    @uri = URI.parse(url)
    @uri.query ||= ""
    @uri.query += URI.encode_www_form(page_params)
    #RACK_ENV["processing_url"] = @uri
    #@prefix = prefix
    begin
      open(@uri.to_s, "User-Agent" => "Mongler Ruby/#{RUBY_VERSION}") do |f|
        @content_type = f.content_type
        @charset = f.charset
        @raw_page = f.read
      end
    rescue OpenURI::HTTPError
      @content_type = "text/plain"
      @charset = "utf-8"
      @raw_page = "teh other server spit out a 404 for url #{@uri.to_s}"
    end
    @doc = nil
    begin
      @doc = Nokogiri(@raw_page)
      @html = true
    rescue StandardError #make sure it doesn't catch SIGTERM and such.
      #assume the document is not html
      @html = false
    end
    @html &&= @content_type.include?("html")
  end
  
  attr_reader :content_type,:charset

  def proxy_uri(page)
    full_goto_url = @uri.merge(page)
    prox_uri = URI("/proxy/#{URI.encode_www_form_component full_goto_url.to_s}/")
    #prox_uri.query = URI.encode_www_form("url" => full_goto_url.to_s)
    return prox_uri
  end

  def proxy_url(page)
    proxy_uri(page).to_s
  end

  def is_url?(url=nil)
    url.nil? ? !@uri.scheme.nil? : !(URI.parse(url).scheme.nil?)
  end

  def mangle(tag, attribute)
    @doc.css(tag).each{|e| e[attribute] = proxy_url(e[attribute]) if !self.is_url?(e[attribute])} if @html
  end

  def parse
    @html ? @doc.to_s : @raw_page
  end
end
