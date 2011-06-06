require 'apartment/railtie'
require 'apartment/config'
require 'apartment/database'

module Apartment

  def self.included(base)
    base.extend Apartment::ClassMethods
  end
end

