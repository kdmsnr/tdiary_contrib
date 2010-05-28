# -*- coding: utf-8 -*-
require 'rubygems'
require 'shoulda'
require 'redgreen'
require 'tdiary_twitter'

class TestTwitter < Test::Unit::TestCase
  should "twitter_title" do
    assert_equal("@tDiary / そういえば、明日で9歳になります!", twitter_title(12425500138))
  end

  should "twitter_tweet" do
    expect =<<-EOS
@tDiary: そういえば、明日で9歳になります!<br />
<a href="http://twitter.com/tDiary/status/12425500138">2010-04-19 09:04:09</a>
<a href="http://simplytweet.com" rel="nofollow">SimplyTweet</a>
EOS
    assert_equal(expect, twitter_tweet(12425500138))
  end

  should "twitter_detail" do
    expect =<<-EOS
<a href="http://twitter.com/tDiary"><img src="http://a3.twimg.com/profile_images/379668735/square_logo_normal.png" border="0" /></a> そういえば、明日で9歳になります!<br />
<a href="http://twitter.com/tDiary/status/12425500138">2010-04-19 09:04:09</a>
<a href="http://simplytweet.com" rel="nofollow">SimplyTweet</a>
EOS
    assert_equal(expect, twitter_detail(12425500138))
  end
end
