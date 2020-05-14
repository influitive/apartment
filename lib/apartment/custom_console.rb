# frozen_string_literal: true

module Apartment
  module CustomConsole
    begin
      require 'pry-rails'
    rescue LoadError
      # rubocop:disable Rails/Output
      puts '[Failed to load pry-rails] If you want to use Apartment custom prompt you need to add pry-rails to your gemfile'
      # rubocop:enable Rails/Output
    end

    desc = "Includes the current Rails environment and project folder name.\n" \
          '[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>'

    prompt_procs = [
      proc { |target_self, nest_level, pry| prompt_contents(pry, target_self, nest_level, '>') },
      proc { |target_self, nest_level, pry| prompt_contents(pry, target_self, nest_level, '*') }
    ]

    if Gem::Version.new(Pry::VERSION) >= Gem::Version.new('0.13')
      Pry.config.prompt = Pry::Prompt.new 'ros', desc, prompt_procs
    else
      Pry::Prompt.add 'ros', desc, %w[> *] do |target_self, nest_level, pry, sep|
        prompt_contents(pry, target_self, nest_level, sep)
      end
    end

    # if Pry::Prompt.respond_to?(:add)
    #   desc = "Includes the current Rails environment and project folder name.\n" \
    #         '[1] [project_name][Rails.env][Apartment::Tenant.current] pry(main)>'

    #   Pry::Prompt.add 'ros', desc, %w[> *] do |target_self, nest_level, pry, sep|
    #     "[#{pry.input_ring.size}] [#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \
    #     "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
    #     "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
    #   end

    #   Pry.config.prompt = Pry::Prompt[:ros][:value]
    #   Pry.config.hooks.add_hook(:when_started, 'startup message') do
    #     tenant_info_msg
    #   end
    # end

    def self.prompt_contents(pry, target_self, nest_level, sep)
      "[#{pry.input_ring.size}] [#{PryRails::Prompt.formatted_env}][#{Apartment::Tenant.current}] " \
      "#{pry.config.prompt_name}(#{Pry.view_clip(target_self)})" \
      "#{":#{nest_level}" unless nest_level.zero?}#{sep} "
    end
  end
end
