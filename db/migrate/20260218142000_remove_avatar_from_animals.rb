class RemoveAvatarFromAnimals < ActiveRecord::Migration[8.0]
  def change
    remove_column :animals, :avatar, :string
  end
end
