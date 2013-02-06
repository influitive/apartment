module ActiveRecord
  class Base

    # Overriding Delayed Job's monkey_patch of ActiveRecord so that it works with Apartment
    yaml_as "tag:ruby.yaml.org,2002:ActiveRecord"

    def self.yaml_new(klass, tag, val)
      Apartment::Database.process(val['database']) do
        klass.find(val['attributes']['id'])
      end
    rescue ActiveRecord::RecordNotFound => e
      raise Delayed::DeserializationError,  e.message
    end

    # Rails > 3.0 now uses encode_with to determine what to encode with yaml
    # @override to include database attribute
    def encode_with_with_database(coder)
      coder['database'] = @database if @database.present?
      encode_with_without_database(coder)
    end
    alias_method_chain :encode_with, :database

    # Remain backwards compatible with old yaml serialization
    def to_yaml_properties
      ['@attributes', '@database']    # add in database attribute for serialization
    end

  end
end