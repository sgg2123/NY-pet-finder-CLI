require_relative '../config/environment'
require 'pry'

welcome
#binding.pry
user_id = sign_up_or_log_in
#binding.pry
welcome_menu(user_id)
