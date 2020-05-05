# frozen_string_literal: true

require 'apartment/model'

class UserWithTenantModel < ApplicationRecord
  include Apartment::Model

  self.table_name = 'users'
  # Dummy models
end
