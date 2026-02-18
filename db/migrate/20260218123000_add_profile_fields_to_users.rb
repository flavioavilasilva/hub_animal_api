class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :user_type, :string, null: false, default: "visitor"
    add_column :users, :address, :jsonb, null: false, default: {}
    add_column :users, :fantasy_name, :string
    add_column :users, :site, :string
    add_column :users, :cpf, :string
    add_column :users, :cnpj, :string
    add_column :users, :responsible, :string

    add_index :users, :cpf, unique: true
    add_index :users, :cnpj, unique: true
    add_index :users, :user_type
  end
end
