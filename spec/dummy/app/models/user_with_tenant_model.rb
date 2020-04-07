# frozen_string_literal: true

class UserWithTenantModel < ApplicationRecord
  include Apartment::Model

  self.table_name = 'users'
  # Dummy models
end
