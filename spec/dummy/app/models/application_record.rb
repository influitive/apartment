# frozen_string_literal: true

# NOTE: Dummy model base
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
