#encoding: utf-8

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  #before_filter :get_page, :except => :index



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
