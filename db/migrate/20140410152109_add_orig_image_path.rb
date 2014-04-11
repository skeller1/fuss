class AddOrigImagePath < ActiveRecord::Migration
  def change
	add_column :matches, :orig_image_path, :string
  end
end
