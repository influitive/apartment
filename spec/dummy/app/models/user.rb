class User < ActiveRecord::Base
  include Apartment::Delayed::Job::Hooks
  def perform; end
  # Dummy models
end