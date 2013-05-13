require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require './lib/mongler'

set :haml, :format=>:html5

get '/' do
  haml :index
end

# Stylesheets
get('/main.css'){sass :main}
get('/proxy.css'){sass :proxy}

get '/proxy' do
  res = mangle_page params[:url]
  content_type res[:content_type], :charset => res[:charset]
  @site = res[:page]
  if res[:content_type] == "text/html" || res[:content_type] == "application/xhtml+xml"
    haml :proxy, :layout => false
  else
    @site
  end
end

def mangle_page(url)
  doc = Mongler.new(url)
  doc.mangle('img', 'src')
  doc.mangle('link', 'href')
  doc.mangle('a', 'href')
  doc.mangle('form', 'action')
  {:content_type => doc.content_type , :charset => doc.charset , :page => doc.parse}
end
