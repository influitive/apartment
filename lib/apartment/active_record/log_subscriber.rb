# frozen_string_literal: true

module ActiveRecord
  # Supports the logging configuration to prepend the database and schema in the ActiveRecord log
  class LogSubscriber
    def apartment_log
      return unless Apartment.active_record_log

      database = color("[#{Apartment.connection.current_database}] ", ActiveSupport::LogSubscriber::MAGENTA, true)
      schema = nil
      unless Apartment.connection.schema_search_path.nil?
        schema = color("[#{Apartment.connection.schema_search_path.tr('"', '')}] ",
                       ActiveSupport::LogSubscriber::YELLOW, true)
      end
      "#{database}#{schema}"
    end

    def payload_binds(binds, type_casted_binds)
      return unless (binds || []).empty?

      casted_params = type_casted_binds(type_casted_binds)
      '  ' + binds.zip(casted_params).map { |attr, value| render_bind(attr, value) }.inspect
    end

    def sql(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload

      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
      name  = "CACHE #{name}" if payload[:cached]
      sql = payload[:sql]
      binds = payload_binds(payload[:binds], payload[:type_casted_binds])

      name = colorize_payload_name(name, payload[:name])
      sql  = color(sql, sql_color(sql), true) if colorize_logging

      debug "    #{apartment_log}#{name} #{sql}#{binds}"
    end
  end
end
