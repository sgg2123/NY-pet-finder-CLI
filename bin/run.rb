require_relative '../config/environment'
require 'pry'

welcome
# binding.pry
user_id = find_or_create_user
hash = location_menu
shelter_id_hash = display_shelter_name(hash)
shelter_id = get_shelter_selection(shelter_id_hash)
pet_hash = get_pets_from_shelter(shelter_id)
pet_id_hash = display_pet_name(pet_hash)
pet_id = get_pet_selection(pet_id_hash)
specific_pet_hash = get_specific_pet_record(pet_id)
display_detailed_pet_info(specific_pet_hash)
do_you_want_to_save?(user_id, pet_id)
