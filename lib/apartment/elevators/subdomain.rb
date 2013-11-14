module Apartment
  module Elevators
    #   Provides a rack based db switching solution based on subdomains
    #   Assumes that database name should match subdomain
    #
    class Subdomain < Generic
      def self.excluded_subdomains
        @@excluded_subdomains ||= []
      end

      def self.excluded_subdomains=(arg)
        @@excluded_subdomains = arg
      end

      def parse_database_name(request)
        request_subdomain = subdomain(request.host)

        # If the domain acquired is set to be exlcluded, set the database to whatever is currently
        # next in line in the schema search path.
        database = if self.class.excluded_subdomains.include?(request_subdomain)
          nil
        else
          request_subdomain
        end

        database.present? && database || nil
      end

    private

      # *Almost* a direct ripoff of ActionDispatch::Request subdomain methods

      # Only care about the first subdomain for the database name
      def subdomain(host)
        subdomains(host).first
      end

      #   Assuming tld_length of 1, might need to make this configurable in Apartment in the future for things like .co.uk
      def subdomains(host, tld_length = 1)
        return [] unless named_host?(host)

        host.split('.')[0..-(tld_length + 2)]
      end

      def named_host?(host)
        !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
      end
    end
  end
end
