class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :url
      t.string :name
      t.references :club
      t.timestamps
    end
  end
end
