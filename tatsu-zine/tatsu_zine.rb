def tatsu_zine_cache_dir
	cache = "#{@cache_path}/tatsu-zine"
	Dir.mkdir( cache ) unless File.directory?( cache )
	cache
end

def tatsu_zine_cache_set( id, result )
	File.open( "#{tatsu_zine_cache_dir}/#{id}", "w" ) do |f|
		f.write result
	end
end

def tatsu_zine_cache_get( id )
	File.open( "#{tatsu_zine_cache_dir}/#{id}", "r" ) do |f|
		f.read
	end
rescue
	nil
end

def tatsu_zine( id, doc = nil )
	if @conf.secure and !(result = tatsu_zine_cache_get(id)).nil?
		return result
	end

	domain = "http://tatsu-zine.com"
	image = "#{domain}/images/books/#{id}/cover_s.jpg"
	link = "#{domain}/books/#{id}"
	require 'open-uri'
	doc ||= open(link)

	require 'rexml/document'
	xml = REXML::Document.new( doc )
	section = "//html/body/div/div[3]/section/div[2]"
	title = REXML::XPath.match( xml, "#{section}/h1" ).first
	author = REXML::XPath.match( xml, "#{section}/p[@class='author']" ).first
	description =
		REXML::XPath.match( xml, "#{section}/div[@class='description']" ).first

	result = <<-EOS
<p><a class="tatsu-zine" href="#{h link}">
  <img src="#{h image}" class="tatsu-zine" alt="#{h title}" height="150" width="100">
  <div class="tatsu-zine-desc">
    <span class="tatsu-zine-title">#{h title}</span><br>
    <span class="tatsu-zine-author">#{h author}</span><br>
    <span class="tatzu-zine-description">#{h description}</span>
  </div>
</a></p>
EOS

	tatsu_zine_cache_set( id, result ) if @conf.secure
	result
end

if $0 == __FILE__
	class Conf
		def secure
			true
		end
	end
	@conf = Conf.new

	def h(str)
		str
	end

	@cache_path = "./"

	puts tatsu_zine(1, File.open("./1.html"){|f| f.read})
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
