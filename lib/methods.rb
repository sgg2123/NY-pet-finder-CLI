require 'rest-client'
require 'json'

def welcome
  puts "Hi do you want a pet? you're in the right place bc you bet your sweet ass, we have pets"
end

def make_request(url)
  #make the web request
  all_characters = RestClient.get(url)
  JSON.parse(all_characters)
end

def menu_valid_input?(input)
  if input == "1" || input == "2"
    true
  else
    false
  end
end

def borough_valid_input?(input)
  if input == "1" || input == "2" || input == "3" || input == "4" || input == "5"
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
#   if menu_valid_input?(input)
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
  if menu_valid_input?(type_input)
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

def shelter_menu
  puts "Please select an NYC borough for your pet search"
  puts "1 - Manhattan"
  puts "2 - Brooklyn"
  puts "3 - The Bronx"
  puts "4 - Queens/Long Island"
  puts "5 - Staten Island"
  input = gets.chomp
  if borough_valid_input?(input)
    if input == "1"
      puts "You have selected Manhattan."
      pet_type_menu("Manhattan")
    elsif input == "2"
      puts "You have selected Brooklyn."
      pet_type_menu("Brooklyn")
    elsif input == "3"
      puts "You have selected The Bronx."
      pet_type_menu("The Bronx")
    elsif input == "4"
      puts "You have selected Queens/ Long Island"
      pet_type_menu("Queens")
    else
      puts "You have selected Staten Island"
      pet_type_menu("Staten Island")
    end
  else
    puts "Invalid input - please select one of the options above"
    shelter_menu
  end
end
