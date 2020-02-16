# frozen_string_literal: true

# rubocop:disable Style/MixinUsage
extend Rails::ConsoleMethods if defined?(Rails) && Rails.env
# rubocop:enable Style/MixinUsage
