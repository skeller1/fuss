#encoding: utf-8

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #http_basic_authenticate_with name: ENV["USER"], password: ENV["PASSWORD"]

  #before_filter :get_page, :except => :index



 def update
	taggler = Rufus::Scheduler.new
	taggler.in '3s' do

		Match.delete_all


		Team.all.each do |team|	

	  		puts "Updating Matches started. Get teams"

		
			league_day=""
			match_id=""
			match_date = DateTime.new
			home = ""
			visitor = ""
			result = ""
			save_path_image = ""
			temp_path_image = ""
			orig_path_image = ""
			@days={}
			@teams =[]

			i = 0
			page = Nokogiri::HTML(open(team.url))
			page.css('table#egmFixtureList tr > td').each do |td|

			

				unless td.previous_sibling
					i = 0
					match_id=""
					match_date = DateTime.new
					home = ""
					visitor = ""
					result = ""
					save_path_image = ""
					Rails.logger.info "#{i} hat keinen vorgänger, start"
				end


				if td["class"].match('egmRowGrouped')
					#Kopf mit Datumsangabe
					#i=0
					league_day = td.content.strip
					match_id=""
					match_date = DateTime.new
					home = ""
					visitor = ""
					result = ""
					save_path_image = ""
				
					@days[league_day]=[]
	    			else
				
								

					i = i+1

				


					str = td.content.strip


					#Rails.logger.info "#{i}"

					unless str.empty?
					
						match_id = str if i == 1
						match_date = DateTime.parse("#{league_day} #{str}") if i == 2
					
						#removing special chars in team names
						str = str.split("\n").first.strip unless str.empty?
	
						home = str if i == 3
						visitor = str if i == 5
					end
		
					#str = str.split("\n").first.strip unless str.empty?
					#@teams << str if i ==3 or i == 5
					#@days[league_day] << str if str.length > 0 and str != "-" and str !="Infos zur Begegnung"and str !="*"

					#BEGIN NEU

	
					td.css("div.egmImagedMatchResult div:first").each do |div|

						#width and height of image
						r=div["style"].try(:match, /width: -?(\d+)px/)	
						width = r[1] if r.present?

						r=div["style"].try(:match, /height: -?(\d+)px/)
						height = r[1] if r.present?

					
						if width.present? and height.present?
	
							div.css("img.egmImagedMatchResult").each do |img|
								#puts 
								# left and top of image							
								r = img["style"].match(/left: -?(\d+)px/)
								left = r[1] if r.present?
								r = img["style"].match(/top: -?(\d+)px/)
								top = r[1] if r.present?
							
								save_path_image = img["src"]
								image = MiniMagick::Image.open(img["src"])
								#image.crop('Width Image x Height Image+ Versatz x(Left)+Versatz y(Top)')								
								image.crop("#{width}x#{height}+#{left}+#{top}")								
								orig_path_image = Rails.root.join("tmp/#{SecureRandom.hex(10)}.png").to_s
								image.write(orig_path_image)

								image.alpha('Off')
								
								image.normalize
								image.negate
								# image magick on heroku creates black image, only use this for local testing							
								image.brightness_contrast('-50') if Rails.env.development?
								image.threshold('31%')
								image.resize('400x')
								image_path = Rails.root.join("tmp/#{SecureRandom.hex(10)}.png")
								image.write(image_path)
								#puts "w: #{width}; h: #{height}; l: #{left}; t: #{top} mit #{img["src"]}"			

								file = Tempfile.new('foo',Rails.root.join("tmp"))
								cmd = "tesseract #{image_path} #{file.path}"		
	
								system(cmd)
								
								temp_path_image = image_path.to_s
	
								r=File.open(file.path+".txt")
								file.unlink		
								result = r.read
							
								r.close

								file.close
								file.unlink



							end
						end				



					end

				
					#if i % 7 == 0
					if td["class"].match(/noPrint/)
						m = Match.new
						m.match_date = match_date
						m.match_id = match_id
						m.home = home
						m.visitor = visitor
						m.team = team
						unless result.empty?
							result = result.split(":")
							m.goals_home = result.first.to_i 
							m.goals_visitor = result.last.to_i
						end
						m.result_image_path = save_path_image
						m.temp_image_path = temp_path_image					
						m.orig_image_path = orig_path_image						
						m.save
						# if match_id.length == 3
						#i=0
						#league_day = td.content.strip
						#match_id=""
						#match_date = DateTime.new
						#home = ""
						#visitor = ""
						#result = ""
					end



				
					#ENDE NEU


	    			end
			end

			puts "daten fertsch"

		end
	
	end
	
	render :text => "ok"

 end


 def image
	@images = Dir.glob(Rails.root.join("tmp/*.png"))
 end


 def index
	
	#file = Tempfile.new('foo')
	#puts cmd = "tesseract ./public/original.png #{file.path}"		
	
	#system(cmd)

	
	#r=File.open(file.path+".txt")
	#file.unlink		
	#@output = r.read

	#r.close

	#file.close
	#file.unlink
		
	#@output =`tesseract #{Rails.root.join("public/original.png")} test 2>&1`
 end

 def list
	#t=Team.where(:name => params[:team]).first
	redirect :league unless params[:teams].present?#t.created_at.to_s
 end


 def league

 end


 def league2
  if params[:url].present?
   @url = params[:url]
   league_day=""
   @days={}
   @teams =[]
   i = 0
   page = Nokogiri::HTML(open(params[:url]))
   page.css('table#egmFixtureList tr > td').each do |day|

    if day["class"].match('egmRowGrouped')
	i=0
	league_day = day.content.strip
	@days[league_day]=[]
    else
	i = i+1
	str = day.content.strip

	str = str.split("\n").first.try(:strip).try(:to_str)
	@teams << str if i ==3 or i == 5
	@days[league_day] << str if str.present? and str != "-" and str !="Infos zur Begegnung"and str !="*"
    end

    @teams.uniq!


   end
  else
	flash[:now] = "Nachricht angeben"
	redirect_to root_url
  end

 end


 private

 def get_page
  if params[:url].present?
   @url = params[:url]
   league_day=""
   @days={}
   @teams =[]
   i = 0
   page = Nokogiri::HTML(open(params[:url]))
   page.css('table#egmFixtureList tr > td').each do |day|

    if day["class"].match('egmRowGrouped')
	i=0
	league_day = day.content.strip
	@days[league_day]=[]
    else
	i = i+1
	str = day.content.strip

	str = str.split("\n").first.try(:strip).try(:to_str)
	@teams << str if i ==3 or i == 5
	@days[league_day] << str if str.present? and str != "-" and str !="Infos zur Begegnung"and str !="*"
    end

    @teams.uniq!


   end
  else
	flash[:now] = "Nachricht angeben"
	redirect_to root_url
  end
 end


end
