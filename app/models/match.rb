class Match < ActiveRecord::Base

 belongs_to :team

 def team_string
  self.team.name.split('(').try(:first).strip
 end

 def home?
  self.team_string == self.home
 end

 def visitor?
  self.team_string == self.visitor
 end

 def points
  if self.goals_home == self.goals_visitor
   self.goals_home == nil ? 0 : 1
  else
   if self.goals_home > self.goals_visitor
    self.home? ? 3 : 0
   else
    self.visitor? ? 3 : 0
   end
  end
 end

end
