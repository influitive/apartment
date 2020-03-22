# frozen_string_literal: true

module Apartment
  module CustomConsole
    begin
      require 'pry-rails'
    rescue LoadError
      puts '[Failed to load pry-rails] If you want to use Apartment custom prompt you need to add pry-rails to your gemfile'
    end

    if Pry::Prompt.respond_to?(:add)
      desc = "Includes the current Rails environment and project folder name.\n" \
            '[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>'

      Pry::Prompt.add 'ros', desc, %w[> *] do |target_self, nest_level, pry, sep|
        "[#{pry.input_ring.size}] [#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \
        "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
        "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
      end

      Pry.config.prompt = Pry::Prompt[:ros][:value]
    end
  end
end
