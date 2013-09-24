class Team < ActiveRecord::Base

	belongs_to :club

	has_many :matches, :dependent => :destroy
end
