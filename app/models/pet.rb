class Pet < ActiveRecord::Base
  has_many :user_pets
  has_many :users, through: :user_pets

  belongs_to :shelter

  has_many :pet_breeds
  has_many :breeds, through: :pet_breeds
end
