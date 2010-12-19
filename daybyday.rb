#!/bin/env ruby
#
# A fun little sinatra app for displaying your personal data day by day. Still
# not sure if this should maybe be in something closer to PHP...
#
# http://www.last.fm/api/show?service=278
# http://pinboard.in/howto/#api
# http://dev.twitter.com/
# http://www.flickr.com/services/api/

require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'

get '/' do
   year   = Time.now.year
   month  = Time.now.month
   day    = Time.now.day
   redirect "/#{year}/#{month}/#{day}/";
end

get '/:year/?' do
   redirect "/#{params[:year]}/1/1/";
end

get '/:year/:month/?' do
   redirect "/#{params[:year]}/#{params[:month]}/1/";
end

def json_request url
   resp = Net::HTTP.get_response(URI.parse(url))
   data = resp.body

   # we convert the returned JSON data to native Ruby
   # data structure - a hash
   result = JSON.parse(data)

   # if the hash has 'Error' as a key, we raise an error
   if result.has_key? 'Error'
      raise "web service error"
   end

   return result
end

get '/:year/:month/:day/?' do
   apikey = "b25b959554ed76058ac220b7b2e0a026"
   user = "icco"
   lastfm_url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&format=json&user=#{user}&api_key=#{apikey}"
   lastfm = json_request lastfm_url

   erb :page, :locals => {
      :lastfm  => lastfm,
      :day     => params[:day],
      :month   => params[:month],
      :year    => params[:year],
   }
end
