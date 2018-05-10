class AddApiPetIdColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :pets, :api_pet_id, :string
  end
end
