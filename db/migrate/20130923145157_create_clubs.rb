class CreateClubs < ActiveRecord::Migration
  def change
    create_table :clubs do |t|
      t.string :url
      t.string :uid
      t.text :infos

      t.timestamps
    end
  end
end
