class CreateAllTables < ActiveRecord::Migration[5.0]
  def change
    create_table :breeds do |t|
      t.string :name
    end

    create_table :pet_breeds do |t|
      t.integer :pet_id
      t.integer :breed_id
    end

    create_table :pets do |t|
      t.string :name
      t.string :animal_type
      t.string :age
      t.string :sex
      t.string :size
      t.datetime :last_update
      t.text :description
      t.string :contact_phone
      t.string :email
      t.integer :shelter_id
      t.string :shelter_number
    end

    create_table :shelters do |t|
      t.string :shelter_number
      t.string :name
      t.string :street_address
      t.string :street_address_2
      t.string :city
      t.string :state
      t.string :phone
      t.string :email
    end

    create_table :users do |t|
      t.string :name
    end

    create_table :user_pets do |t|
      t.integer :user_id
      t.integer :pet_id
    end

  end
end
