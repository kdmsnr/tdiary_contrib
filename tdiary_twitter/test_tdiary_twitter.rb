# -*- coding: utf-8 -*-
require 'rubygems'
require 'shoulda'
require 'redgreen'
require 'tdiary_twitter'

class TestTwitter < Test::Unit::TestCase

	should "twitter_title" do
		assert_equal('<div class="twitter">@tDiary / そういえば、明日で9歳になります!</div>', twitter_title(12425500138))
	end

	should "twitter_tweet" do
		expect =<<-EOS
<div class="twitter">@tDiary: そういえば、明日で9歳になります!<br />
<a href="http://twitter.com/tDiary/status/12425500138">2010-04-19 09:04:09</a>
<a href="http://simplytweet.com" rel="nofollow">SimplyTweet</a></div>
EOS
		assert_equal(expect.chomp, twitter_tweet(12425500138))
	end

	should "twitter_detail" do
		expect =<<-EOS
<div class="twitter"><a href="http://twitter.com/tDiary"><img src="http://a3.twimg.com/profile_images/379668735/square_logo_normal.png" border="0" /></a> そういえば、明日で9歳になります!<br />
<a href="http://twitter.com/tDiary/status/12425500138">2010-04-19 09:04:09</a>
<a href="http://simplytweet.com" rel="nofollow">SimplyTweet</a></div>
EOS
		assert_equal(expect.chomp, twitter_detail(12425500138))
	end

	should "twitter_tree" do
		expect =<<-EOS
<div class="twitter"><a href="http://twitter.com/hsbt"><img src="http://a3.twimg.com/profile_images/324464297/DSC00731_normal.jpg" border="0" /></a> @tDiary おめでとうございます! wishlist を公開してください<br />
<a href="http://twitter.com/hsbt/status/12425723279">2010-04-19 09:09:03</a>
<a href="http://coderepos.org/share/browser/lang/ruby/misc/tig.rb" rel="nofollow">tig.rb</a></div>
<div class="twitter"><a href="http://twitter.com/tDiary"><img src="http://a3.twimg.com/profile_images/379668735/square_logo_normal.png" border="0" /></a> @hsbt つ http://www.cozmixng.org/retro/projects/tdiary/tickets<br />
<a href="http://twitter.com/tDiary/status/12435185771">2010-04-19 12:21:52</a>
<a href="http://www.tweetdeck.com" rel="nofollow">TweetDeck</a></div>
EOS
		assert_equal(expect.chomp, twitter_tree(12435185771))
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

