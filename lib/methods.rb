require 'rest-client'
require 'json'
require 'pry'
require 'colorize'
require 'terminal-table'
require 'launchy'

def welcome
  puts "-----------------------------------------".blue
  puts "Welcome to the NYC Adoptable Pets Search!".blue
  puts "-----------------------------------------".blue
end

def sign_up_or_log_in
  puts "\n"
  puts "Please sign up or login.".blue
  puts "------------------------".blue
  puts "1 - Sign Up"
  puts "2 - Login"
  puts "3 - exit"
  puts "\n"
  sign_up_or_log_in_input = gets.chomp
  if valid_input?(sign_up_or_log_in_input, 3)
    if sign_up_or_log_in_input == "1"
      create_new_user
    elsif sign_up_or_log_in_input == "2"
      find_existing_user
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    sign_up_or_log_in
  end
end

def find_existing_user
  puts "\n"
  puts "Please enter your username.".blue
  puts "System is case sensitive.".blue.italic
  puts "---------------------------".blue
  input = gets.chomp
  if User.find_by(name: input)
    username = User.find_by(name: input)
    puts "\nWelcome back #{username.name}.\n".blue
    username.id
  else
    puts "\n"
    puts "Username not found - please re-enter or sign up.".red
    sign_up_or_log_in
  end
end

def create_new_user
  puts "\n"
  puts "Please enter your desired username.".blue
  puts "System is case sensitive.".blue.italic
  puts "-----------------------------------".blue
  input = gets.chomp
  if !User.find_by(name: input)
    username = User.create(name: input)
    puts "\nWelcome #{username.name}.\n".blue
    username.id
  else
    puts "\n"
    puts "Username already in use - please enter another.".red
    sign_up_or_log_in
  end
end

def welcome_menu(user_id)
  puts "\n"
  puts "Would you like to perform a search or view your saved pets?".blue
  puts "-----------------------------------------------------------".blue
  puts "1 - View Saved Data"
  puts "2 - Perform a Search"
  puts "3 - exit"
  puts "\n"
  welcome_menu_input = gets.chomp
  if valid_input?(welcome_menu_input, 3)
    if welcome_menu_input == "1"
      saved_menu(user_id)
    elsif welcome_menu_input == "2"
      define_the_search(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    welcome_menu(user_id)
  end
end

############################## SEARCH STUFF ####################################

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

def run_a_search_by_location(user_id)
  hash = location_menu
  shelter_id_hash = display_shelter_name(hash)
  shelter_id = get_shelter_selection(user_id, shelter_id_hash)
  pet_hash = get_pets_from_shelter(shelter_id)
  pet_id_hash = display_pet_name(pet_hash)
  pet_id = get_pet_selection(user_id, pet_id_hash)
  specific_pet_hash = get_specific_pet_record(pet_id)
  display_detailed_pet_info(specific_pet_hash)
  do_you_want_to_save?(user_id, pet_id)
end

def run_a_search_by_pet_type(user_id)
  hash = pet_type_menu
  pet_id_hash = display_pet_name(hash)
  pet_id = get_pet_selection(user_id, pet_id_hash)
  specific_pet_hash = get_specific_pet_record(pet_id)
  display_detailed_pet_info(specific_pet_hash)
  do_you_want_to_save?(user_id, pet_id)
end


def location_menu
  puts "\n"
  puts "Please select an NYC borough for your pet search.".blue
  puts "-------------------------------------------------".blue
  puts "1 - Manhattan"
  puts "2 - Brooklyn"
  puts "3 - The Bronx"
  puts "4 - Queens"
  puts "5 - Staten Island"
  puts "6 - exit"
  puts "\n"
  input = gets.chomp
  if valid_input?(input, 6)
    if input == "1"
      puts "\n"
      puts "You have selected Manhattan.".blue
      puts "----------------------------".blue
      shelter_menu("Manhattan")
    elsif input == "2"
      puts "\n"
      puts "You have selected Brooklyn.".blue
      puts "---------------------------".blue
      shelter_menu("Brooklyn")
    elsif input == "3"
      puts "\n"
      puts "You have selected The Bronx.".blue
      puts "----------------------------".blue
      shelter_menu("The Bronx")
    elsif input == "4"
      puts "\n"
      puts "You have selected Queens.".blue
      puts "-------------------------".blue
      shelter_menu("Queens")
    elsif input == "5"
      puts "\n"
      puts "You have selected Staten Island.".blue
      puts "--------------------------------".blue
      shelter_menu("Staten Island")
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
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
  puts "\n"
  puts "Here is your selected list of pets.".blue
  puts "-----------------------------------".blue
  hash["petfinder"]["pets"].map do |pet, returned_array|
    returned_array.map do |array|
      results_hash[counter] = array["id"]["$t"]
      puts "#{counter}. #{array["name"]["$t"]}"
      puts "-- type: #{array["animal"]["$t"]}"
      puts "-- sex: #{array["sex"]["$t"]}"
      puts "-- breed(s): #{breed_array(array)}"
      puts "-- size: #{array["size"]["$t"]}"
      puts "-- age: #{array["age"]["$t"]}"
      puts "-- city: #{array["contact"]["city"]["$t"]}"
###########################################################################################################################
      puts "\n"
      counter += 1
    end
  end
  puts "#{counter} - Main Menu"
  puts "\n"
  puts "#{counter + 1} - exit"
  puts "\n"
  results_hash
end

def get_shelter_selection(user_id, shelter_id_hash)
  puts "Please select a shelter by number to view all pets available at that location".blue
  puts "-----------------------------------------------------------------------------".blue
  shelter_selection = gets.chomp
  if valid_input?(shelter_selection, shelter_id_hash.length+2)
    if shelter_selection.to_i.between?(1,shelter_id_hash.length)
      shelter_id_hash[shelter_selection.to_i]
    elsif shelter_selection.to_i == shelter_id_hash.length+1
      puts "Returning to main menu".blue
      puts "----------------------".blue
      puts "\n"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    get_shelter_selection(user_id, shelter_id_hash)
  end
end

def get_pets_from_shelter(shelter_id)
  make_request("http://api.petfinder.com/shelter.getPets?key=1201cf858e44c5465a854617015774a5&id=#{shelter_id}&format=json")
end

def get_pet_selection(user_id, pet_id_hash)
  puts "\n"
  puts "Please select a pet by number to view more details for this pet.".blue
  puts "----------------------------------------------------------------".blue
  pet_selection = gets.chomp
  if valid_input?(pet_selection, pet_id_hash.length+2)
    if valid_input?(pet_selection, pet_id_hash.length)
      pet_id_hash[pet_selection.to_i]
    elsif pet_selection.to_i == pet_id_hash.length+1
      puts "\n"
      puts "Returning to main menu".blue
      puts "----------------------".blue
      puts "\n"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Goodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    get_pet_selection(user_id, pet_id_hash)
  end
end

def get_specific_pet_record(pet_id)
  make_request("http://api.petfinder.com/pet.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_id}&format=json")
end

def display_detailed_pet_info(hash)
  puts "\n"
  puts "Here are the details for your selected pet.".blue
  puts "-------------------------------------------".blue
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
  puts "-- city: #{is_nil?(hash["petfinder"]["pet"]["contact"]["city"])}"
  puts "-- state: #{is_nil?(hash["petfinder"]["pet"]["contact"]["state"])}"
  puts "-- zip: #{is_nil?(hash["petfinder"]["pet"]["contact"]["zip"])}"
#########################################################################################################

  would_you_like_to_open_pictures?(hash)
end

def would_you_like_to_open_pictures?(hash)
  puts "\n"
  puts "Would you like to open a picture of this pet in your browser?".blue
  puts "-------------------------------------------------------------".blue
  puts "1 - Yes"
  puts "2 - No"
  puts "\n"
  open_pics = gets.chomp
  if valid_input?(open_pics, 2)
    if open_pics == "1"
      if hash["petfinder"]["pet"]["media"]["photos"]["photo"][2] == nil || !hash["petfinder"]["pet"]["media"]["photos"]["photo"][2] == [] || hash["petfinder"]["pet"]["media"]["photos"]["photo"][2] == {}
        puts "No photos available"
      else
        Launchy.open(hash["petfinder"]["pet"]["media"]["photos"]["photo"][2]["$t"])
      end
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    would_you_like_to_open_pictures?(hash)
  end
end

def do_you_want_to_save?(user_id, pet_id)
  puts "\n"
  puts "Would you like to save this pet?".blue
  puts "--------------------------------".blue
  puts "1 - Yes"
  puts "2 - No"
  puts "\n"
  input = gets.chomp
  if valid_input?(input, 2)
    if input == "1"
      save_a_pet(user_id, pet_id)
      puts "\n"
      puts "Returning to the main menu.".blue
      puts "---------------------------".blue
      puts "\n"
      welcome_menu(user_id)
    else
      puts "\n"
      puts "Pet not saved. Returning to the main menu.".blue
      puts "------------------------------------------".blue
      puts "\n"
      welcome_menu(user_id)
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
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

def save_a_pet(user_id, pet_id)
  pet_data = make_request("http://api.petfinder.com/pet.get?key=1201cf858e44c5465a854617015774a5&id=#{pet_id}&format=json")

  pet_data_hash = pet_data["petfinder"]["pet"]

  if !Pet.find_by(api_pet_id: pet_id)
    saved_pet = Pet.create(
      name: is_nil?(pet_data_hash["name"]),
      animal_type: is_nil?(pet_data_hash["animal"]),
      age: is_nil?(pet_data_hash["age"]),
      sex: is_nil?(pet_data_hash["sex"]),
      size: is_nil?(pet_data_hash["size"]),
      last_update: is_nil?(pet_data_hash["lastUpdate"]),
      description: is_nil?(pet_data_hash["description"]),
      contact_phone: is_nil?(pet_data_hash["contact"]["phone"]),
      email: is_nil?(pet_data_hash["contact"]["email"]),
      shelter_number: is_nil?(pet_data_hash["shelterId"]),
      api_pet_id: pet_id
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
  else
    saved_pet = Pet.find_by(api_pet_id: pet_id)
  end

  if !User.find_by(id: user_id).pets.include?(saved_pet)
    User.find_by(id: user_id).pets << saved_pet
    puts "\n"
    puts "Pet saved!".green
  else
    puts "\n"
    puts "You have already saved this pet.".blue
  end

end

def define_the_search(user_id)
  puts "\n"
  puts "Would you like to search the NYC area by pet type or search pets by shelters in an NYC borough?".blue
  puts "-----------------------------------------------------------------------------------------------".blue
  puts "1 - Search by Pet Type"
  puts "2 - Search by Borough"
  puts "\n"
  search_request_input = gets.chomp
  if valid_input?(search_request_input, 2)
    if search_request_input == "1"
      run_a_search_by_pet_type(user_id)
    else
      run_a_search_by_location(user_id)
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    define_the_search(user_id)
  end

end


def pet_type_menu
  puts "\n"
  puts "Would you like to search for dogs or cats?".blue
  puts "------------------------------------------".blue
  puts "1 - Dogs"
  puts "2 - Cats"
  puts "3 - exit"
  puts "\n"
  type_input = gets.chomp
  if valid_input?(type_input, 3)
    if type_input == "1"
      narrow_your_search("dogs", "&animal=dog")
    elsif type_input == "2"
      narrow_your_search("cats", "&animal=cat")
    else
      puts "\nGoodbye!".blue
      exit!
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    pet_type_menu
  end
end

def narrow_your_search(selection, type)
  puts "\n"
  puts "You've selected #{selection}! Select a criteria to narrow your search:".blue
  puts "--------------------------------------------------------------".blue
  puts "1 - Age (Baby, Young, Adult, Senior)"
  puts "2 - Sex (M, F)"
  puts "3 - Size (S, M, L, XL)"
  puts "4 - Breed (Select from List)"
  puts "5 - Don't narrow my search! Display a list of 25 pets in the NYC area."
  puts "\n"
  selection_input = gets.chomp
  if valid_input?(selection_input, 5)
    case selection_input
      when "1"
        select_age_option(type)
      when "2"
        select_sex_option(type)
      when "3"
        select_size_option(type)
      when "4"
        select_breed_option(type)
      when "5"
        make_generic_pet_request(type)
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    narrow_your_search(selection, type)
  end
end

def make_generic_pet_request(type)
  make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY#{type}&format=json")
end

def select_age_option(type)
  puts "\n"
  puts "Please enter one of the following options: Baby, Young, Adult, Senior".blue
  puts "---------------------------------------------------------------------".blue
  age_selection = gets.chomp
  if age_selection.downcase == "baby" || age_selection.downcase == "young" || age_selection.downcase == "adult" || age_selection.downcase == "senior"
    make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY#{type}&age=#{age_selection.downcase.capitalize}&format=json")
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    select_age_option(type)
  end
end

def select_size_option(type)
  puts "\n"
  puts "Please enter one of the following options: S, M, L, XL".blue
  puts "------------------------------------------------------".blue
  size_selection = gets.chomp
  if size_selection.upcase == "S" || size_selection.upcase  == "M" || size_selection.upcase  == "L" || size_selection.upcase  == "XL"
    make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY#{type}&size=#{size_selection.upcase}&format=json")
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    select_size_option(type)
  end
end

def select_sex_option(type)
  puts "\n"
  puts "Please enter one of the following options: M, F".blue
  puts "-----------------------------------------------".blue
  sex_selection = gets.chomp
  if sex_selection.upcase == "M" || sex_selection.upcase == "F"
    make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY#{type}&sex=#{sex_selection.upcase}&format=json")
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    select_sex_option(type)
  end
end

def select_breed_option(type)
  breed_list = make_request("http://api.petfinder.com/breed.list?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY&#{type}&format=json")
  counter_and_breed_hash = display_breed_list(breed_list)
  puts "\n"
  puts "Please enter a number for the breed you would like to search for.".blue
  puts "Please note if pets of your selected breed are not currently available in NYC, pets closest to the area will be listed.".blue.italic
  puts "-----------------------------------------------------------------------------------------------------------------------".blue
  breed_selection = gets.chomp
  if valid_input?(breed_selection, counter_and_breed_hash.length)
    if breed_selection.to_i.between?(1,counter_and_breed_hash.length)
      make_request("http://api.petfinder.com/pet.find?key=1201cf858e44c5465a854617015774a5&location=New%20York%20NY#{type}&breed=#{change_breed_name_to_url_friendly(counter_and_breed_hash[breed_selection.to_i])}&format=json")
    end
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    select_breed_option(type)
  end
end

def display_breed_list(breed_list)
  counter = 1
  breed_list_hash = {}
  puts "\n"
  breed_list["petfinder"]["breeds"]["breed"].map do |breed|
    puts "#{counter}. #{breed["$t"]}"
    breed_list_hash[counter] = breed["$t"]
    counter+=1
  end
  breed_list_hash
end

def change_breed_name_to_url_friendly(selection)
  selection.gsub(' ', '%20')
end

################# SAVED STUFF ##############################################

def saved_menu(user_id)
  puts "\n"
  puts "What would you like to view?".blue
  puts "----------------------------".blue
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
  else
    puts "\n"
    puts "Invalid input - please enter a valid option.".red
    saved_menu(user_id)
  end
end

def view_saved_pets(user_id)
  user = User.find(user_id)
  rows = []
  user.pets.map do |pet|
    rows << [pet.name, pet.animal_type, pet.sex, (pet.breeds.map {|breed| breed.name}).join(", "), pet.age, pet.size, pet.contact_phone, pet.email, pet.shelter.name]
  end
  table = Terminal::Table.new :title => "SAVED PETS", :headings => ['Name', 'Type', 'Sex', 'Breeds', 'Age', 'Size', 'Phone #', 'Email', 'Shelter'], :rows => rows
  puts "\n"
  puts table
  puts "\n"
  puts "Would you like to view Shelters for Saved Pets or return to the main menu?".blue
  puts "--------------------------------------------------------------------------".blue
  puts "1 - View Shelters for Saved Pets"
  puts "2 - Main Menu"
  puts "3 - exit"
  puts "\n"
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
    rows << [pet.name, pet.shelter.name, pet.shelter.street_address, pet.shelter.city, pet.shelter.state, pet.shelter.phone, pet.shelter.email]
  end
  table = Terminal::Table.new :title => "SHELTERS FOR SAVED PETS", :headings => ['Pet Name', 'Shelter Name', 'Address', 'City', 'State', 'Phone', 'Email'], :rows => rows
  puts "\n"
  puts table
  puts "\n"
  puts "Would you like to view Saved Pets or return to the Main Menu?".blue
  puts "-------------------------------------------------------------".blue
  puts "1 - View Saved Pets"
  puts "2 - Main Menu"
  puts "3 - exit"
  puts "\n"
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
end
