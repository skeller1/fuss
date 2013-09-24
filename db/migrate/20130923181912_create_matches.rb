class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.datetime :match_date
      t.string :match_id
      t.string :home
      t.string :visitor
      t.integer :goals_home
      t.integer :goals_visitor
      t.references :team
      t.timestamps
    end
  end
end
