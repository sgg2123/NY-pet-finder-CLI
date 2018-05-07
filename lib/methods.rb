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

def main_menu
  puts "How would you like to search for a pet?"
  puts "1. Pet Type (i.e. dog, cat)"
  puts "2. Shelter Location by NYC Borough"
  input = gets.chomp
  if menu_valid_input?(input)
    if input == "1"
      pet_type_menu
    else
      shelter_menu
    end
  else
    puts "Invalid input - please select one of the options above"
    main_menu
  end
end

def pet_type_menu
  puts "Would you like to search for dogs or cats?"
  puts "1 - Dogs"
  puts "2 - Cats"
  type_input = gets.chomp
  if menu_valid_input?(type_input)
    if type_input == "1"
      make_request(url)
    else
      puts "you picked cats"
    end
  else
    puts "Invalid input - please select one of the options above"
    pet_type_menu
  end
end

def shelter_menu
  puts "Which borough would you like to search?"
  puts "1 - Manhattan"
  puts "2 - Brooklyn"
  puts "3 - The Bronx"
  puts "4 - Queens/Long Island"
  puts "5 - Staten Island"
  input = gets.chomp
  if borough_valid_input?(input)
    if input == "1"
      puts "You picked Manhattan"
    elsif input == "2"
      puts "You picked Brooklyn"
    elsif input == "3"
      puts "You picked The Bronx"
    elsif input == "4"
      puts "you picked Queens"
    else
      puts "you picked Staten Island"
    end
  else
    puts "Invalid input - please select one of the options above"
    shelter_menu
  end
end
