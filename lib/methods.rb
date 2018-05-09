require 'rest-client'
require 'json'
require 'pry'
require 'colorize'
require 'terminal-table'

def welcome
  puts "----------------------------------------------------".blue
  puts "Welcome!".blue
  puts "----------------------------------------------------".blue
end

def find_or_create_user
  puts "Please enter your first and last name.".blue
  puts "----------------------------------------------------".blue
  input = gets.chomp
  username = User.find_or_create_by(name: input)
  puts "\n"
  puts "Welcome #{username.name}. Your UserId is #{username.id}.".blue
  puts "\n"
  username.id
end

def make_request(url)
  all_characters = RestClient.get(url)
  JSON.parse(all_characters)
end

def valid_input?(input, max_num)
  if input.to_i.between?(1, max_num)
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

def pet_type_menu(borough)
  puts "Would you like to search for dogs or cats?".blue
  puts "----------------------------------------------------".blue
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
    puts "Invalid input - please select one of the options above".red
    pet_type_menu(borough)
  end
end

def location_menu
  puts "Please select an NYC borough for your pet search".blue
  puts "----------------------------------------------------".blue
  puts "1 - Manhattan"
  puts "2 - Brooklyn"
  puts "3 - The Bronx"
  puts "4 - Queens/Long Island"
  puts "5 - Staten Island"
  puts "6 - exit"
  input = gets.chomp
  if valid_input?(input, 6)
    if input == "1"
      puts "\n"
      puts "You have selected Manhattan.".blue
      puts "----------------------------------------------------".blue
      shelter_menu("Manhattan")
    elsif input == "2"
      puts "\n"
      puts "You have selected Brooklyn.".blue
      puts "----------------------------------------------------".blue
      shelter_menu("Brooklyn")
    elsif input == "3"
      puts "\n"
      puts "You have selected The Bronx.".blue
      puts "----------------------------------------------------".blue
      shelter_menu("The Bronx")
    elsif input == "4"
      puts "\n"
      puts "You have selected Queens/ Long Island".blue
      puts "----------------------------------------------------".blue
      shelter_menu("Queens")
    elsif input == "5"
      puts "\n"
      puts "You have selected Staten Island".blue
      puts "----------------------------------------------------".blue
      shelter_menu("Staten Island")
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "Invalid input - please select a valid option.".red
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
  puts "#{counter} - Main Menu"
  puts "\n"
  puts "#{counter + 1} - exit"
  puts "\n"
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
  puts "#{counter} - Main Menu"
  puts "\n"
  puts "#{counter + 1} - exit"
  puts "\n"
  results_hash
end

def get_shelter_selection(shelter_id_hash)
  puts "Please select a shelter by number to view all pets available at that location".blue
  puts "----------------------------------------------------".blue
  shelter_selection = gets.chomp
  if valid_input?(shelter_selection, shelter_id_hash.length+2)
    if shelter_selection.to_i.between?(1,shelter_id_hash.length)
      shelter_id_hash[shelter_selection.to_i]
    elsif shelter_selection.to_i == shelter_id_hash.length+1
      puts "Returning to main menu".blue
      puts "----------------------------------------------------".blue
      puts "\n"
      location_menu
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "Invalid selection, please select a valid option.".red
    get_shelter_selection(shelter_id_hash)
  end
end

def get_pets_from_shelter(shelter_id)
  make_request("http://api.petfinder.com/shelter.getPets?key=1201cf858e44c5465a854617015774a5&id=#{shelter_id}&format=json")
end

def get_pet_selection(pet_id_hash)
  puts "Please select a pet by number to view more details for this pet".blue
  puts "----------------------------------------------------".blue
  pet_selection = gets.chomp
  if valid_input?(pet_selection, pet_id_hash.length+2)
    if valid_input?(pet_selection, pet_id_hash.length)
      pet_id_hash[pet_selection.to_i]
    elsif pet_selection.to_i == pet_id_hash.length+1
      puts "Returning to main menu".blue
      puts "----------------------------------------------------".blue
      puts "\n"
      location_menu
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "Invalid selection, please select a valid option.".red
    get_pet_selection(pet_id_hash)
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

def do_you_want_to_save?(user_id, pet_id, shelter_id)
  puts "Would you like to save this pet?".blue
  puts "----------------------------------------------------".blue
  puts "1 - Yes"
  puts "2 - No"
  puts "\n"
  input = gets.chomp
  if valid_input?(input, 2)
    if input == "1"
      save_a_pet(user_id, pet_id, shelter_id)
      puts "Pet saved! Returning to the main menu.".blue
      puts "----------------------------------------------------".blue
      welcome_menu(user_id)
    else
      puts "Pet not saved. Would you like to view details for another pet from the list?".blue
      puts "----------------------------------------------------".blue
      puts "1 - Yes (go back)"
      puts "2 - No (exit)"
      second_input = gets.chomp
        if valid_input?(second_input, 2)
          if second_input == "1"
            get_pets_from_shelter(shelter_id)
          else
            puts "Returning to the main menu".blue
            puts "----------------------------------------------------".blue
            puts "\n"
            welcome_menu(user_id)
          end
        end
    end
  else
    puts "Invalid input - please select a valid option.".red
    do_you_want_to_save?(user_id, pet_id)
  end
end

def is_nil?(values)
  if values == [] || values == {} || values == nil
    values = "Information not available"
  else
    values["$t"]
  end
end

def run_a_search(user_id)
  hash = location_menu
  shelter_id_hash = display_shelter_name(hash)
  shelter_id = get_shelter_selection(shelter_id_hash)
  pet_hash = get_pets_from_shelter(shelter_id)
  pet_id_hash = display_pet_name(pet_hash)
  pet_id = get_pet_selection(pet_id_hash)
  specific_pet_hash = get_specific_pet_record(pet_id)
  display_detailed_pet_info(specific_pet_hash)
  do_you_want_to_save?(user_id, pet_id, shelter_id)
end

def welcome_menu(user_id)
  puts "Would you like to perform a search or view your saved pets?".blue
  puts "----------------------------------------------------".blue
  puts "1 - View Saved Data"
  puts "2 - Perform a Search"
  puts "3 - exit"
  welcome_menu_input = gets.chomp
  if valid_input?(welcome_menu_input, 3)
    if welcome_menu_input == "1"
      saved_menu(user_id)
    elsif welcome_menu_input == "2"
      run_a_search(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "Invalid input - please select one of the options above".red
    welcome_menu(user_id)
  end
end

def save_a_pet(user_id, pet_id, shelter_id)
  pet_data = make_request("http://api.petfinder.com/pet.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_id}&format=json")

  pet_data_hash = pet_data["petfinder"]["pet"]

  saved_pet = Pet.find_or_create_by(
    name: is_nil?(pet_data_hash["name"]),
    animal_type: is_nil?(pet_data_hash["animal"]),
    age: is_nil?(pet_data_hash["age"]),
    sex: is_nil?(pet_data_hash["sex"]),
    size: is_nil?(pet_data_hash["size"]),
    last_update: is_nil?(pet_data_hash["lastUpdate"]),
    description: is_nil?(pet_data_hash["description"]),
    contact_phone: is_nil?(pet_data_hash["contact"]["phone"]),
    email: is_nil?(pet_data_hash["contact"]["email"]),
    shelter_number: is_nil?(pet_data_hash["shelterId"])
  )

  breed_values =  pet_data_hash["breeds"]["breed"]
  if breed_values.class == Array
    breed_values.each {|breed| saved_pet.breeds << Breed.find_or_create_by(name: "#{breed["$t"]}")}
  else
    saved_pet.breeds << Breed.find_or_create_by(name: "#{breed_values["$t"]}")
  end

  shelter_data = make_request("http://api.petfinder.com/shelter.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_data["petfinder"]["pet"]["shelterId"]["$t"]}&format=json")
  shelter_data_hash = shelter_data["petfinder"]["shelter"]

  saved_shelter = Shelter.find_or_create_by(
    shelter_number: is_nil?(shelter_data_hash["id"]),
    name: is_nil?(shelter_data_hash["name"]),
    street_address: is_nil?(shelter_data_hash["address1"]),
    street_address_2: is_nil?(shelter_data_hash["address2"]),
    city: is_nil?(shelter_data_hash["city"]),
    state: is_nil?(shelter_data_hash["state"]),
    phone: is_nil?(shelter_data_hash["phone"]),
    email: is_nil?(shelter_data_hash["email"])
  )

  saved_pet.shelter = saved_shelter

  User.find_by(id: user_id).pets << saved_pet
end

###### SAVED STUFF ######

def saved_menu(user_id)
  puts "What would you like to view?".blue
  puts "----------------------------------------------------".blue
  puts "1 - View Saved Pets"
  puts "2 - View Shelters for Saved Pets"
  puts "3 - Main Menu"
  puts "4 - exit"
  puts "\n"
  saved_menu_input = gets.chomp
  if valid_input?(saved_menu_input, 4)
    if saved_menu_input == "1"
      view_saved_pets(user_id)
    elsif saved_menu_input == "2"
      view_saved_shelters(user_id)
    elsif saved_menu_input == "3"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  end

#when a user selects to view their saved stuff - ask them what they want to view?
end

def view_saved_pets(user_id)
  user = User.find(user_id)
  rows = []
  user.pets.map do |pet|
    rows << [pet.name, pet.animal_type, pet.sex, (pet.breeds.map {|breed| breed.name}).join(", "), pet.age, pet.size, pet.contact_phone, pet.email, pet.shelter.name]
  end
  #if user selects see my saved pets, run this Pet.all method
  table = Terminal::Table.new :title => "SAVED PETS", :headings => ['Name', 'Type', 'Sex', 'Breeds', 'Age', 'Size', 'Phone #', 'Email', 'Shelter'], :rows => rows
  puts "\n"
  puts table
  puts "\n"
  puts "Would you like to view Shelters for Saved Pets or return to the main menu?"
  puts "1 - View Shelters for Saved Pets"
  puts "2 - Main Menu"
  puts "3 - exit"
  saved_pet_input = gets.chomp
  if valid_input?(saved_pet_input, 3)
    if saved_pet_input == "1"
      view_saved_shelters(user_id)
    elsif saved_pet_input == "2"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  end
end

def view_saved_shelters(user_id)
  user = User.find(user_id)
  rows = []
  user.pets.map do |pet|
    rows << [pet.shelter.name, pet.shelter.city, pet.shelter.state, pet.shelter.phone, pet.shelter.email]
  end
  #if user selects see my saved pets, run this Pet.all method
  table = Terminal::Table.new :title => "SHELTERS FOR SAVED PETS", :headings => ['Shelter Name', 'City', 'State', 'Phone', 'Email'], :rows => rows
  puts "\n"
  puts table
  puts "\n"
  puts "Would you like to view Saved Pets or return to the Main Menu?"
  puts "1 - View Saved Pets"
  puts "2 - Main Menu"
  puts "3 - exit"
  saved_shelter_input = gets.chomp
  if valid_input?(saved_shelter_input, 3)
    if saved_shelter_input == "1"
      view_saved_pets(user_id)
    elsif saved_shelter_input == "2"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  end
  #if user selects see saved shelters, run this map method
end
