alias :_orig_subtitle_link :subtitle_link
def subtitle_link( date, index, subtitle )
	if @cgi.params['section'].join('') != ''
		index = @cgi.params['section'][0]
	end
	r = _orig_subtitle_link( date, index, subtitle )
	r.gsub(/#p(\d+)/){"&section=#{$1}"}
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
