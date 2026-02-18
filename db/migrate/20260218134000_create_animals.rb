class CreateAnimals < ActiveRecord::Migration[8.0]
  def change
    create_table :animals do |t|
      t.string :avatar
      t.string :name, null: false
      t.jsonb :tags, null: false, default: []
      t.string :size, null: false
      t.date :birth_date
      t.references :responsible, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :animals, :size
  end
end
