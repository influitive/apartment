module Apartment
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def copy_files
      template "apartment.rb", File.join("config", "initializers", "apartment.rb")
    end

  end
end
