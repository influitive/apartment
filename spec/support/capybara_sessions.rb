module RSpec
  module Integration
    module CapybaraSessions
      
      def in_new_session(&block)
        yield new_session
      end
      
      def new_session
        Capybara::Session.new(Capybara.current_driver, Capybara.app)
      end
      
    end
  end
end