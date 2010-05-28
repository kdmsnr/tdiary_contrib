require 'rubygems'
require 'open-uri'
require 'json'
require 'time'

def twitter_title( id )
  twitter_format(id, "@:screen_name / :text")
end

def twitter_tweet( id )
  format =<<-EOS
@:screen_name: :text<br />
:created_at
:source
EOS
  twitter_format(id, format)
end

def twitter_detail( id )
  format =<<-EOS
:profile_image :text<br />
:created_at
:source
EOS
  twitter_format( id , format)
end

# TBD
# def twitter_tree( id )
# end

def twitter_format( id, format = "@:screen_name / :text" )
  json =   open("http://twitter.com/status/show/#{id}.json").read
  parsed = JSON.parse( json )

  format.gsub!(/:screen_name/, parsed["user"]["screen_name"])
  format.gsub!(/:text/, parsed["text"])
  format.gsub!(/:source/, parsed["source"])
  t = Time.parse parsed["created_at"]
  format.gsub!(/:created_at/,
               %Q|<a href="http://twitter.com/#{parsed["user"]["screen_name"]}/status/#{id}">#{t.strftime("%Y-%m-%d %H:%M:%S")}</a>|)
  format.gsub!(/:profile_image/,
               %Q|<a href="http://twitter.com/#{parsed["user"]["screen_name"]}"><img src="#{parsed["user"]["profile_image_url"]}" border="0" /></a>|)

  return format
end

def twitter( id )
  twitter_tweet( id )
end
