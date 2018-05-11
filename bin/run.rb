require_relative '../config/environment'
require 'pry'

welcome
user_id = sign_up_or_log_in
welcome_menu(user_id)
