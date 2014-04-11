class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]


  before_action :set_season, only: [:now, :season]

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
  end

  # GET /teams/new
  def new
    @team = Team.new
  end


  #Aktuelles Match des Teams
  def now
   @matches = @matches.by_weekend(field: :match_date)
  end  

  def season
   
  end



  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render action: 'show', status: :created, location: @team }
      else
        format.html { render action: 'new' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    
    def set_season
	@team = Team.find(params[:id])
	@team_string = @team.name.split('(').try(:first).strip
	
	@arel_matches = Match.arel_table
	@matches = Match.where(@arel_matches[:home].eq(@team_string).or(@arel_matches[:visitor].eq(@team_string))).where(team: @team)

	#@matches = Match.where(team: @team)
	#@home_matches = @matches.where(home: @team_string)
	#@guest_matches = @matches.where(visitor: @team_string)
	
	@siege = 0
	@unentschieden = 0
	@niederlagen = 0
	@spiele	= 0
	@punkte = 0


	@matches.each do |m|
		@punkte = @punkte+m.points
		
		@spiele = @spiele + 1 unless m.goals_home == nil


		case m.points
		when 0
		 unless m.goals_home == nil
		  @niederlagen = @niederlagen + 1
 		 end
		when 1
		 @unentschieden = @unentschieden + 1
		else
		 @siege = @siege + 1
		end	
	end




	@tore_home = @matches.where(home: @team_string).sum(:goals_home)
	@tore_visitor = @matches.where(visitor: @team_string).sum(:goals_visitor)
	@tore = @tore_home+@tore_visitor

	@gegentore_home = @matches.where.not(home: @team_string).sum(:goals_home)
	@gegentore_visitor = @matches.where.not(visitor: @team_string).sum(:goals_visitor)
	@gegentore = @gegentore_home + @gegentore_visitor
	
    end

    def set_team
      @team = Team.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def team_params
      params.require(:team).permit(:url, :name)
    end
end
