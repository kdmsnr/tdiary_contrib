# -*- coding: utf-8 -*-
# data_mapper_io.rb
#
# TODO:
#   * ついでに設定ファイルもDBに
#   * ついでにキャッシュファイルもDB（？）に
#   * DBの設定を設定ファイルで行うように
#   * 複数人のときどうすんの？（設定ファイルでデータベース名決める？）

require 'rubygems'
require 'dm-core'

DataMapper::setup(:default, ENV['DATABASE_URL'] || 'sqlite3:db.sqlite3')

module TDiary
	module DataMapper
		class Diary
			include ::DataMapper::Resource
			storage_names[:default] = 'diaries'

			property :date, String, :key => true
			property :title, String
			property :body, Text, :lazy => false
			property :format, String, :nullable => false
			property :visible, Boolean, :nullable => false, :default => true
			property :last_modified, Time
			auto_upgrade!

			has n, :comments, :child_key => [:diary_date], :order => [:id]
			has n, :referers, :child_key => [:diary_date], :order => [:url]

			def style
				format
			end

			def to_tdiary_model
				klass = TDiary::const_get( "#{style.capitalize}Diary" )
				tdiary = klass.new(date, title, body)
				tdiary.show(visible?)

				comments.to_a.each do |c|
					tc = TDiary::Comment.new(c.name, c.mail, c.body, c.date)
					tc.show = c.visible?
					tdiary.add_comment tc
				end

				referers.to_a.each do |r|
					tdiary.add_referer(r.url, r.count)
				end

				tdiary
			end
		end

		class Comment
			include ::DataMapper::Resource
			storage_names[:default] = 'comments'

			property :id, Serial, :key => true
			property :diary_date, String, :nullable => false
			property :name, String
			property :mail, String
			property :body, String
			property :date, Time
			property :visible, Boolean, :nullable => false, :default => true
			auto_upgrade!

			belongs_to :diary, :child_key => [:diary_date]
		end

		class Referer
			include ::DataMapper::Resource
			storage_names[:default] = 'referers'
			
			property :diary_date, String, :key => true
			property :url, String, :key => true
			property :count, Integer
			auto_upgrade!
			
			belongs_to :diary, :child_key => [:diary_date]
		end

		class Config
			include ::DataMapper::Resource
			storage_names[:default] = 'configs'

			property :id,  Integer, :key => true
			property :body, Text, :lazy => false
			auto_upgrade!
		end
	end

	require 'tdiary/defaultio'
	class DataMapperIO < DefaultIO
		def transaction( date )
			ym = date.strftime("%Y%m")
			date = date.strftime("%Y%m%d")
			diaries = {}

			DataMapper::Diary.all( :date.like => "#{ym}%" ).to_a.each do |dm|
				diaries[dm.date.to_s] = dm.to_tdiary_model
			end

			dirty = yield( diaries )

			tdiary = diaries[date]
			return unless tdiary
			
			case dirty
			when TDiaryBase::DIRTY_NONE
				return
			when TDiaryBase::DIRTY_DIARY
				dm = DataMapper::Diary.get( date )
				unless dm
					dm = DataMapper::Diary.new( :date => date )
				end
				dm.attributes = {
					:title => tdiary.title,
					:body => tdiary.to_src,
					:visible => tdiary.visible?,
					:format => tdiary.style,
					:last_modified => tdiary.last_modified
				}
				dm.save
			when TDiaryBase::DIRTY_COMMENT
				tdiary.each_comment do |c|
					cm = DataMapper::Comment.first(:diary_date => date,
															 :name => c.name,
															 :mail => c.mail,
															 :body => c.body)
					unless cm
						cm = DataMapper::Comment.new(:diary_date => date,
															  :name => c.name,
															  :mail => c.mail,
															  :body => c.body)
					end
					cm.attributes = {
						:visible => c.visible?,
						:date => c.date
					}
					cm.save
				end
			when TDiaryBase::DIRTY_REFERER
				tdiary.each_referer do |count, r|
					rm = DataMapper::Referer.get(date, r)
					unless rm
						rm = DataMapper::Referer.new(:diary_date => date, :url => r)
					end
					rm.attributes = {
						:count => count
					}
					rm.save
				end
			end
		end
	end

	class Config
		# saving to tdiary.conf in DB
		def save
			result = ERB::new( File::open( "#{PATH}/skel/tdiary.rconf" ){|f| f.read }.untaint ).result( binding )
			result.untaint unless @secure
			
			# TODO: think about ID
			config = DataMapper::Config.get(1)
			unless config
				config = DataMapper::Config.new( :id => 1 )
			end
			config.body = result
			config.save
		end

		def load_cgi_conf
			begin
				def_vars1 = ''
				def_vars2 = ''
				[
					:tdiary_version,
					:html_title, :author_name, :author_mail, :index_page, :hour_offset,
					:description, :icon, :banner,
					:header, :footer,
					:section_anchor, :comment_anchor, :date_format, :latest_limit, :show_nyear,
					:theme, :css,
					:show_comment, :comment_limit, :comment_limit_per_day,
					:mail_on_comment, :mail_header,
					:show_referer, :no_referer2, :only_volatile2, :referer_table2,
					:options2,
				].each do |var|
					def_vars1 << "#{var} = nil\n"
					def_vars2 << "@#{var} = #{var} unless #{var} == nil\n"
				end
				
				# TODO: think about ID
				config = DataMapper::Config.get(1)
				unless config
					config = DataMapper::Config.new( :id => 1 )
					config.save
				end

				cgi_conf = config
				cgi_conf.untaint unless @secure

				b = binding.taint
				eval( def_vars1, b )
				Safe::safe( @secure ? 4 : TDIARY_SAFE_NORMAL ) do
					begin
						eval( cgi_conf.to_s, b, "(TDiary::Config#load_cgi_conf)", 1 )
					rescue SyntaxError
						enc = case @lang
							when 'en'
								'UTF-8'
							when 'zh'
								'Big5'
							else
								'EUC-JP'
							end
						cgi_conf.force_encoding( enc )
						# retry
					end
				end
				eval( def_vars2, b )
			rescue IOError, Errno::ENOENT
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3

