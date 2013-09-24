class TeamObserver < ActiveRecord::Observer
  def after_create(team)
	
	if team.url == "http://ergebnisdienst.fussball.de/staffelspielplan/vogtlandklasse/kreis-vogtland/kreisliga-a/herren/spieljahr1314/sachsen/-/staffel/01HHAGMMFG000000VV0AG812VU110IET-G/mandant/63"
	taggler = Rufus::Scheduler.new
	taggler.in '3s' do
  		puts "Team Oberserver after create started. Get teams"

		
		league_day=""
		match_id=""
		match_date = DateTime.new
		home = ""
		visitor = ""
		result = ""
		save_path_image = ""

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
					r=div["style"].match(/width: -?(\d+)px/)	
					width = r[1] if r.present?

					r=div["style"].match(/height: -?(\d+)px/)
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
							image.alpha('Off')
							image.crop("#{width}x#{height}+#{left}+#{top}")
							image.normalize
							image.negate
							# image magick on heroku creates black image, only use this for local testing							
							image.brightness_contrast('-50') if Rails.env.development?
							image.threshold('31%')
							image.resize('500x')
							image_path = Rails.root.join("tmp/#{SecureRandom.hex(10)}.png")
							image.write(image_path)
							#puts "w: #{width}; h: #{height}; l: #{left}; t: #{top} mit #{img["src"]}"			

							file = Tempfile.new('foo')
							cmd = "tesseract #{image_path} #{file.path}"		
	
							system(cmd)

	
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

		#@days.keys.each do |d|

			#@days[d].each_slice(4) do |g|
				
				
				#puts "#{g[0]} #{g[1]} #{g[2]} #{g[3]} #{g[4]}"
		#		m = Match.new
		#		m.match_date = DateTime.parse("#{d} #{g[1]}")
		#		m.match_id = g[0] if g[0].present?
		#		m.home = g[2] if g[2].present?
		#		m.visitor = g[3] if g[3].present?
		#		m.team = team


				

			
				#m.save if g[0].length == 3
			#end


		#end


		puts "daten fertsch"

		#puts @days



	end

	#end if only one writing to record
	end
  
   #end after create
   end

end
