module ActiveRecord
  class Base
    
    # Overriding Delayed Job's monkey_patch of ActiveRecord so that it works with Apartment
    yaml_as "tag:ruby.yaml.org,2002:ActiveRecord"
    
    def self.yaml_new(klass, tag, val)
      Apartment::Database.process(val['database']) do
        klass.find(val['attributes']['id'])
      end
    rescue ActiveRecord::RecordNotFound
      raise Delayed::DeserializationError
    end
    
    def to_yaml_properties
      ['@attributes', '@database']    # add in database attribute for serialization
    end
    
  end
end