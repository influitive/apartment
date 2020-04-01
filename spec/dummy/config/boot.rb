# frozen_string_literal: true

require 'rubygems'

gemfile = File.expand_path('../../../Gemfile', __dir__)

if File.exist?(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
