# frozen_string_literal: true

namespace :authorio do
  desc 'Set password for initial Authorio user'
  require 'io/console'

  def input_no_echo(prompt)
    print("\n#{prompt}")
    $stdin.noecho(&:gets).chop
  end

  task password: :environment do
    passwd = input_no_echo('Enter new password: ')
    passwd_confirm = input_no_echo('Confirm password: ')
    Authorio::User.create_with(password: passwd, password_confirmation: passwd_confirm)
                  .find_or_create_by!(profile_path: '/')
    puts("\nPassword set")
  end
end
