# frozen_string_literal: true

require 'active_record/log_subscriber'

module Apartment
  # Custom Log subscriber to include database name and schema name in sql logs
  class LogSubscriber < ActiveRecord::LogSubscriber
    # NOTE: for some reason, if the method definition is not here, then the custom debug method is not called
    # rubocop:disable Lint/UselessMethodDefinition
    def sql(event)
      super(event)
    end
    # rubocop:enable Lint/UselessMethodDefinition

    private

    def debug(progname = nil, &block)
      progname = "  #{apartment_log}#{progname}" unless progname.nil?

      super(progname, &block)
    end

    def apartment_log
      database = color("[#{Apartment.connection.raw_connection.db}] ", ActiveSupport::LogSubscriber::MAGENTA, true)
      schema = nil
      unless Apartment.connection.schema_search_path.nil?
        schema = color("[#{Apartment.connection.schema_search_path.tr('"', '')}] ",
                       ActiveSupport::LogSubscriber::YELLOW, true)
      end
      "#{database}#{schema}"
    end
  end
end
