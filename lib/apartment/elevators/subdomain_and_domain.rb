module Apartment
  module Elevators
    # Provides a rack based db switching solution based on subdomains
    # Assumes that database name should match subdomain and domain
    class SubdomainAndDomain < Generic
      def parse_database_name(request)
        domain = request.domain.present? && request.domain || nil
        subdomain = request.subdomain.present? && request.subdomain || nil

        domain = domain.gsub(/[\.-]/, '_') unless domain.nil?
        subdomain = subdomain.gsub(/[\.-]/, '_') unless subdomain.nil?

        if domain and subdomain #and not Rails.env.test?
          "#{subdomain}_#{domain}"
        else
          nil
        end
      end
    end
  end
end