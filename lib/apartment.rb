module Apartment
	require 'apartment/railtie'
	require 'apartment/config'
	require 'apartment/database'

  def self.included(base)
    base.extend Apartment::ClassMethods
  end
end

