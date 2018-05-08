require 'rest-client'
require 'json'
require 'pry'

def welcome
  puts "Hi do you want a pet? you're in the right place bc we have pets"
end

def find_or_create_user
  puts "Please enter your first and last name."
  input = gets.chomp
  if !User.all.find_by(name: input)
    username = User.create(name: input)
  else
    username = User.all.find_by(name: input)
  end
  puts "Welcome #{username.name}. Your UserId is #{username.id}."
  username.id
end

def make_request(url)
  #make the web request
  all_characters = RestClient.get(url)
  JSON.parse(all_characters)
end

def valid_input?(input, max_num)
  if input.to_i.between?(1,max_num)
    true
  else
    false
  end
end

def borough_to_url_string(borough)
  case borough
    when "Manhattan"
      "Manhattan%20NY"
    when "Brooklyn"
      "Brooklyn%20NY"
    when "The Bronx"
      "The%20Bronx%20NY"
    when "Queens/ Long Island"
      "Queens%20NY"
    when "Staten Island"
      "Staten%20Island%20NY"
    else
      "New%20York%20NY"
  end
end

# def main_menu
#   puts "How would you like to search for a pet?"
#   puts "1. Pet Type (i.e. dog, cat)"
#   puts "2. Shelter Location by NYC Borough"
#   input = gets.chomp
#   if valid_input?(input, 2)
#     if input == "1"
#       pet_type_menu
#     else
#       shelter_menu
#     end
#   else
#     puts "Invalid input - please select one of the options above"
#     main_menu
#   end
# end

def pet_type_menu(borough)
  puts "Would you like to search for dogs or cats?"
  puts "1 - Dogs"
  puts "2 - Cats"
  type_input = gets.chomp
  if valid_input?(type_input, 2)
    if type_input == "1"
      to_interpolate = borough_to_url_string(borough)
      data = make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&animal=dog&location=#{to_interpolate}&format=json")
    else
      to_interpolate = borough_to_url_string(borough)
      data = make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&animal=cat&location=#{to_interpolate}&format=json")
    end
  else
    puts "Invalid input - please select one of the options above"
    pet_type_menu(nil)
  end
end

# def shelter_menu
#   puts "Please select an NYC borough for your pet search"
#   puts "1 - Manhattan"
#   puts "2 - Brooklyn"
#   puts "3 - The Bronx"
#   puts "4 - Queens/Long Island"
#   puts "5 - Staten Island"
#   input = gets.chomp
#   if valid_input?(input, 5)
#     if input == "1"
#       puts "You have selected Manhattan."
#       pet_type_menu("Manhattan")
#     elsif input == "2"
#       puts "You have selected Brooklyn."
#       pet_type_menu("Brooklyn")
#     elsif input == "3"
#       puts "You have selected The Bronx."
#       pet_type_menu("The Bronx")
#     elsif input == "4"
#       puts "You have selected Queens/ Long Island"
#       pet_type_menu("Queens")
#     else
#       puts "You have selected Staten Island"
#       pet_type_menu("Staten Island")
#     end
#   else
#     puts "Invalid input - please select one of the options above"
#     shelter_menu
#   end
# end

def location_menu
  puts "Please select an NYC borough for your pet search"
  puts "1 - Manhattan"
  puts "2 - Brooklyn"
  puts "3 - The Bronx"
  puts "4 - Queens/Long Island"
  puts "5 - Staten Island"
  input = gets.chomp
  if valid_input?(input, 5)
    if input == "1"
      puts "You have selected Manhattan."
      shelter_menu("Manhattan")
    elsif input == "2"
      puts "You have selected Brooklyn."
      shelter_menu("Brooklyn")
    elsif input == "3"
      puts "You have selected The Bronx."
      shelter_menu("The Bronx")
    elsif input == "4"
      puts "You have selected Queens/ Long Island"
      shelter_menu("Queens")
    else
      puts "You have selected Staten Island"
      shelter_menu("Staten Island")
    end
  else
    puts "Invalid input - please select one of the options above"
    location_menu
  end
end

def shelter_menu(borough)
  to_interpolate = borough_to_url_string(borough)
  data = make_request("http://api.petfinder.com/shelter.find?key=1201cf858e44c5465a854617015774a5&location=#{to_interpolate}&format=json")
end

def display_shelter_name(hash)
  counter = 1
  results_hash = {}
  hash["petfinder"]["shelters"].map do |shelter, returned_array|
    returned_array.map do |array|
      results_hash[counter] = array["id"]["$t"]
      puts "#{counter}. #{array["name"]["$t"]}"
      puts "-- zip: #{array["zip"]["$t"]}"
      puts "\n"
      counter += 1
      #binding.pry
    end
  end
  results_hash
end

def breed_array(array)
  if array["breeds"]["breed"].class == Array
    new_array = array["breeds"]["breed"].map {|array| array["$t"]}
    string = new_array.join(", ")
  else
    array["breeds"]["breed"]["$t"]
  end
end

def final_breed_array(values)
  if values.class == Array
    new_array = values.map {|array| array["$t"]}
    string = new_array.join(", ")
  else
    values["$t"]
  end
end

def display_pet_name(hash)
  counter = 1
  results_hash = {}
  hash["petfinder"]["pets"].map do |pet, returned_array|
    returned_array.map do |array|
      # binding.pry
      results_hash[counter] = array["id"]["$t"]
      puts "#{counter}. #{array["name"]["$t"]}"
      puts "-- type: #{array["animal"]["$t"]}"
      puts "-- sex: #{array["sex"]["$t"]}"
      puts "-- breed(s): #{breed_array(array)}"
      puts "-- size: #{array["size"]["$t"]}"
      puts "-- age: #{array["age"]["$t"]}"
      puts "\n"
      counter += 1
      #binding.pry
    end
  end
  results_hash
end

def get_shelter_selection(shelter_id_hash)
  puts "Please select a shelter by number to view all pets available at that location"
  shelter_selection = gets.chomp
  if valid_input?(shelter_selection, 25)
    shelter_id_hash[shelter_selection.to_i]
  else
    get_shelter_selection(shelter_id_hash)
  end
end

def get_pets_from_shelter(shelter_id)
  make_request("http://api.petfinder.com/shelter.getPets?key=1201cf858e44c5465a854617015774a5&id=#{shelter_id}&format=json")
end


def get_pet_selection(pet_id_hash)
  puts "Please select a pet by number to view more details for this pet"
  pet_selection = gets.chomp
  if valid_input?(pet_selection, pet_id_hash.length)
    pet_id_hash[pet_selection.to_i]
  else
    pet_id_hash(pet_id_hash)
  end
end

def get_specific_pet_record(pet_id)
  make_request("http://api.petfinder.com/pet.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_id}&format=json")
end

def display_detailed_pet_info(hash)
  puts hash["petfinder"]["pet"]["name"]["$t"]
  puts "-- type: #{hash["petfinder"]["pet"]["animal"]["$t"]}"
  puts "-- breed(s): #{final_breed_array(hash["petfinder"]["pet"]["breeds"]["breed"])}"
  puts "-- sex: #{hash["petfinder"]["pet"]["sex"]["$t"]}"
  puts "-- size: #{hash["petfinder"]["pet"]["size"]["$t"]}"
  puts "-- age: #{hash["petfinder"]["pet"]["age"]["$t"]}"
  puts "-- description: #{hash["petfinder"]["pet"]["description"]["$t"]}"
  puts "\n"
  puts "Contact Info:"
  puts "-- phone: #{is_nil?(hash["petfinder"]["pet"]["contact"]["phone"])}"
  puts "-- email: #{is_nil?(hash["petfinder"]["pet"]["contact"]["email"])}"
  puts "-- street address: #{is_nil?(hash["petfinder"]["pet"]["contact"]["address"])}"
end

def do_you_want_to_save?(user_id, pet_id)
  puts "Would you like to save this pet?"
  puts "1 - Yes"
  puts "2 - No"
  input = gets.chomp
  if valid_input?(input, 2)
    save_a_pet(user_id, pet_id)
  else
    puts "Alrighty then. WE HAVE TO GO BACK"
  end
end

def is_nil?(values)
  if values == [] || values == {} || values == nil
    values = "Information not available"
  else
    values["$t"]
  end
end

def save_a_pet(user_id, pet_id)
  pet_data = make_request("http://api.petfinder.com/pet.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_id}&format=json")

  saved_pet = Pet.new(
    name: is_nil?(pet_data["petfinder"]["pet"]["name"]),
    animal_type: is_nil?(pet_data["petfinder"]["pet"]["animal"]),
    age: is_nil?(pet_data["petfinder"]["pet"]["age"]),
    sex: is_nil?(pet_data["petfinder"]["pet"]["sex"]),
    size: is_nil?(pet_data["petfinder"]["pet"]["size"]),
    last_update: is_nil?(pet_data["petfinder"]["pet"]["lastUpdate"]),
    description: is_nil?(pet_data["petfinder"]["pet"]["description"]),
    contact_phone: is_nil?(pet_data["petfinder"]["pet"]["contact"]["phone"]),
    email: is_nil?(pet_data["petfinder"]["pet"]["contact"]["email"]),
    shelter_number: is_nil?(pet_data["petfinder"]["pet"]["shelterId"])
  )

  shelter_data = make_request("http://api.petfinder.com/shelter.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_data["petfinder"]["pet"]["shelterId"]["$t"]}&format=json")
  saved_shelter = Shelter.new(
    shelter_number: is_nil?(shelter_data["petfinder"]["shelter"]["id"]),
    name: is_nil?(shelter_data["petfinder"]["shelter"]["name"]),
    street_address: is_nil?(shelter_data["petfinder"]["shelter"]["address1"]),
    street_address_2: is_nil?(shelter_data["petfinder"]["shelter"]["address2"]),
    city: is_nil?(shelter_data["petfinder"]["shelter"]["city"]),
    state: is_nil?(shelter_data["petfinder"]["shelter"]["state"]),
    phone: is_nil?(shelter_data["petfinder"]["shelter"]["phone"]),
    email: is_nil?(shelter_data["petfinder"]["shelter"]["email"])
  )

  saved_pet.shelter = saved_shelter

  User.find_by(id: user_id).pets << saved_pet
  binding.pry
end
