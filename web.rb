require 'sinatra'
require 'open-uri'

class SiteReader
  def initialize(url)
    @siteIO = open(url)
  end

  def each
    @siteIO.gets("\n",65535)
  end
end

get('/'){"wrkz"}
get('*'){
  SiteReader.new(request.url)
}
