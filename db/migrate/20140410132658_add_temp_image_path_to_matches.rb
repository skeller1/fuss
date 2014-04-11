class AddTempImagePathToMatches < ActiveRecord::Migration
  def change
    add_column :matches, :temp_image_path, :string
  end
end
