class ClubObserver < ActiveRecord::Observer
  def after_create(club)
	
	taggler = Rufus::Scheduler.new
	taggler.in '3s' do
  		puts "Club Oberserver after create started. Get teams"

		page = Nokogiri::HTML(open(club.url))
	
		#puts = page.html   		

#<td class="egmClubInfo egmClubInfoTeams">
#<a class="egmFixturesLink" href="http://ergebnisdienst.fussball.de/begegnungen/vogtlandklasse/kreis-vogtland/kreisliga-a/herren/#spieljahr1314/sachsen/-/staffel/01HHAGMMFG000000VV0AG812VU110IET-G/mandant/63">
#SG&nbsp;Jößnitz (Herren)</a>
#</td>

		page.css('td.egmClubInfoTeams a.egmFixturesLink').each do |team|		
			t= Team.new
			t.name = team.content.strip
			t.club = club
			t.url = team["href"].gsub("begegnungen","staffelspielplan")
			t.save
		end

		#sleep 20
		puts "rufus fertsch"
	end	

    #contact.logger.info('New contact added!')
  end

  def after_destroy(club)
    #contact.logger.warn("Contact with an id of #{contact.id} was destroyed!")
  end
end
