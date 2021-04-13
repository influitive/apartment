# frozen_string_literal: true

# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/apartment/(.+)\.rb$})     { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^lib/apartment/(.+)\.rb$})     { |m| "spec/integration/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { 'spec' }
end
