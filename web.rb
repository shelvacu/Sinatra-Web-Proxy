#require 'sinatra'
require 'open-uri'
require 'gserver'

class LogServ < GServer
  def initialize(port=ARGV[1],*args)
    super port,*args
  end

  def serve(io)
    $stdout.puts io.gets
  end
end

serv = LogServ.new
serv.start
serv.join

=begin
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
=end
