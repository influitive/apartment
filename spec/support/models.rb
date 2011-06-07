# Used to stub out Rails models from our app
# Note that we shouldn't have to do this... A better setup would be to give a configuration
# object that can take an array of db names to iterate over

require 'active_record'

module Admin
  class Company < ActiveRecord::Base
  end
end

class User < ActiveRecord::Base
end