# category_similar.rb:
#   * shows similar posts under the diary
#   * depends on plugin/category.rb
# You can redistribute it and/or modify it under the same license as tDiary.

def category_similar( categories = [], max_item = 3)
	info = Category::Info.new(@cgi, @years, @conf)
	months = [['01', '02', '03'], ['04', '05', '06'], ['07', '08', '09'], ['10', '11', '12']][@date.strftime("%m").to_i / (3 + 1)] # quarter
	years = { @date.strftime("%Y") => months }
	hash = @category_cache.categorize(info.category, years)
	items = []
	hash.values_at(*categories).inject({}){|r, i|
		r.merge i unless i.nil?
	}.to_a.each do |ymd_ary|
		ymd = ymd_ary[0]
		ary = ymd_ary[1]
		next if ymd == @date.strftime('%Y%m%d')
		t = Time.local(ymd[0,4], ymd[4,2], ymd[6,2]).strftime(@conf.date_format)
		ary.each do |idx, title, excerpt|
			items << %Q|<a href="#{h @index}#{anchor "#{ymd}#p#{'%02d' % idx}"}" title="#{h excerpt}">#{t}#p#{'%02d' % idx}</a> #{apply_plugin(title)}|
		end
	end
	
	unless items.empty?
		"<h3 class='category-similar'>#{category_similar_label}</h3>" +
		"<ul>" +
		items.sort.reverse[0, max_item].map{|i| "<li>#{i}</i>" }.join("\n") +
		"</ul>"
	end
end

add_body_leave_proc do |date, idx|
	diary = @diaries[date.strftime('%Y%m%d')]
	if @mode =~ /day/ and diary.categorizable?
		categories = []
		diary.each_section do |s|
			categories += s.categories unless s.categories.empty?
		end
		category_similar(categories)
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
