module Authorio
  class InstallGenerator < Rails::Generators::Base

    def self.source_paths
      paths = []
      paths << File.expand_path('../templates', "../../#{__FILE__}")
      paths << File.expand_path('../templates', "../#{__FILE__}")
      paths << File.expand_path('../templates', __FILE__)
      paths.flatten
    end

    def add_files
      template 'authorio.rb', 'config/initializers/authorio.rb'
    end

  end
end
