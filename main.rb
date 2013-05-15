require 'sinatra'
require 'haml'
require 'sass'
require 'open-uri'
require 'pp'
require './lib/mongler'

set :haml, :format=>:html5

error 404 do
  "You didn't put in a url! How could you!(this may be a bug in the code)"
end

get '/' do
  haml :index
end

# Stylesheets
get('/main.css'){sass :main}
get('/proxy.css'){sass :proxy}

get '/proxy' do
  error 404 if params[:url].nil?
  redirect "/proxy/#{URI.encode_www_form_component params[:url]}/"
end

get '/proxy/*/*' do
  error 404 if params[:splat].nil?
  params[:splat][1] ||= ""
  url = params[:splat].first
  page_params = params
  page_params.delete(:splat)
  res = mangle_page url+(page_params.empty? ? '' : '?'+URI.encode_www_form(page_params)),{}
  if res[:charset].nil?
    content_type res[:content_type]
  else
    content_type res[:content_type], :charset => res[:charset]
  end
  @site = res[:page]
  if res[:content_type] == "text/html" || res[:content_type] == "application/xhtml+xml"
    haml :proxy, :layout => false
  else
    @site
  end
end

def mangle_page(url,p)
  doc = Mongler.new(url,p)
  doc.mangle('img', 'src')
  doc.mangle('link', 'href')
  doc.mangle('a', 'href')
  doc.mangle('form', 'action')
  {:content_type => doc.content_type , :charset => doc.charset , :page => doc.parse}
end
