# You can redistribute it and/or modify it under the same license as tDiary.

def facebook_like(url, options = {})
	default_options = {
		:layout => :standard,
		:show_faces => :true,
		:width => 450,
		:action => :like,
		:colorscheme => :light
	}
	options = default_options.merge(options)
	options[:height] = (options[:layout] == :standard) ? 80 : 21

	%Q|<iframe class="facebook-like" src="http://www.facebook.com/plugins/like.php?href=#{url}&amp;layout=#{options[:layout]}&amp;show_faces=#{options[:show_faces]}&amp;width=#{options[:width]}&amp;action=#{options[:like]}&amp;font&amp;colorscheme=#{options[:colorscheme]}&amp;height=#{options[:height]}" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:450px; height:80px;" allowTransparency="true"></iframe>|
end

add_section_leave_proc do |date, index|
	options = {
		:layout => @conf["facebook_like.layout"],
		:show_faces => @conf["facebook_like.show_faces"],
		:width => @conf["facebook_like.width"],
		:action => @conf["facebook_like.action"],
		:colorscheme => @conf["facebook_like.colorscheme"]
	}
	anc = date.strftime('%Y%m%d') + "#p" + sprintf("%02d", index)
	facebook_like("#{@index}#{anchor(anc)}", options)
end

add_conf_proc("FacebookLike", "Facebook Like", "etc") do
	if @mode == 'saveconf'
		@cgi.params.each do |k, v|
			if k =~ /\Afacebook_like\.(.*)/
				@conf["facebook_like.#{$1}"] = v[0]
			end
		end
	end

	if @conf["facebook_like.width"].empty?
		@conf["facebook_like.width"] = 450
	end

	<<-HTML
<h2>Facebook Like</h2>

<h3>Layout Style</h3>
<select name="facebook_like.layout">
<option value="standard"#{@conf['facebook_like.layout'] == 'standard' ? ' selected' : ''}>standard</option>
<option value="button_count"#{@conf['facebook_like.layout'] == 'button_count' ? ' selected' : ''}>button_count</option>
</select>

<h3>Show Faces</h3>
<select name="facebook_like.show_faces">
<option value="true"#{@conf['facebook_like.show_faces'] == 'true' ? ' selected' : ''}>show</option>
<option value="false"#{@conf['facebook_like.show_faces'] == 'false' ? ' selected' : ''}>hide</option>
</select>



<h3>Width</h3>
<p><input name="facebook_like.width" value="#{h @conf['facebook_like.width']}" /></p>

<h3>Verb to display</h3>
<select name="facebook_like.action">
<option value="like"#{@conf['facebook_like.action'] == 'like' ? ' selected' : ''}>like</option>
<option value="recommend"#{@conf['facebook_like.action'] == 'recommend' ? ' selected' : ''}>recommend</option>
</select>

<h3>Color Scheme</h3>
<select name="facebook_like.colorscheme">
<option value="light"#{@conf['facebook_like.colorscheme'] == 'light' ? ' selected' : ''}>light</option>
<option value="dark"#{@conf['facebook_like.colorscheme'] == 'dark' ? ' selected' : ''}>dark</option>
</select>

HTML
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

