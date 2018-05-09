require_relative '../config/environment'
require 'pry'

welcome
#binding.pry
user_id = find_or_create_user
#binding.pry
welcome_menu(user_id)
