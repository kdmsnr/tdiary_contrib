# You can redistribute it and/or modify it under the same license as tDiary.
#
# USAGE
#   title: {{twitter_title 12425500138}}
#   tweet: {{twitter_tweet 12425500138}} or {{twitter 12425500138}}
#   tree:  {{twitter_tree 12435185771}}
#   detail: {{twitter_detail 12425500138}}

require 'rubygems'
require 'open-uri'
require 'json'
require 'time'

def twitter_title( id )
	twitter_format(twitter_json( id ), "@:screen_name / :text")
end

def twitter_tweet( id )
	format =<<-EOS
@:screen_name: :text<br />
:created_at
:source
EOS
	twitter_format(twitter_json( id ), format)
end

def twitter_detail( id )
	format =<<-EOS
:profile_image :text<br />
:created_at
:source
EOS
	twitter_format( twitter_json( id ), format)
end

def twitter_tree( id )
	format =<<-EOS
:profile_image :text<br />
:created_at
:source
EOS

	results = []
	while ( id )
		parsed = twitter_json( id )
		id = parsed["in_reply_to_status_id"]
		result = twitter_format( parsed, format )
		results << result
	end
	results.reverse.join("\n")
end

def twitter_format( parsed, format = "@:screen_name / :text" )
	result = format.dup
	result.gsub!(/:screen_name/, parsed["user"]["screen_name"])
	result.gsub!(/:text/, parsed["text"])
	result.gsub!(/:source/, parsed["source"])
	t = Time.parse parsed["created_at"]
	result.gsub!(/:created_at/,
					 %Q|<a href="http://twitter.com/#{parsed["user"]["screen_name"]}/status/#{parsed["id"]}">#{t.strftime("%Y-%m-%d %H:%M:%S")}</a>|)
	result.gsub!(/:profile_image/,
					 %Q|<a href="http://twitter.com/#{parsed["user"]["screen_name"]}"><img src="#{parsed["user"]["profile_image_url"]}" border="0" /></a>|)
	return %Q|<div class="twitter">#{result.chomp}</div>|
end

def twitter( id )
	twitter_tweet( id )
end

private
def twitter_json( id )
	json = open("http://twitter.com/status/show/#{id}.json").read
	return JSON.parse( json )
end


# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

