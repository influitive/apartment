if defined?(ActiveRecord)
  class ActiveRecord::Base
    # @override
    # serialize to YAML
    def encode_with(coder)
      coder["attributes"] = @attributes
      coder["database"] =   @database unless @database.nil?
      coder.tag = ['!ruby/ActiveRecord', self.class.name].join(':')
    end
  end
end

module Psych
  module Visitors
    class ToRuby
      #   @override
      #
      #   NOTE I don't have a great idea what's going on here...
      #   The only change is the `Apartment::Database.process`
      #
      def visit_Psych_Nodes_Mapping_with_class_and_db(object)
        return revive(Psych.load_tags[object.tag], object) if Psych.load_tags[object.tag]

        case object.tag
        when /^!ruby\/ActiveRecord:(.+)$/
          klass = resolve_class($1)
          payload = Hash[*object.children.map { |c| accept c }]
          id = payload["attributes"][klass.primary_key]
          begin
            Apartment::Database.process(payload['database']) do
              klass.unscoped.find(id)
            end
          rescue ActiveRecord::RecordNotFound
            raise Delayed::DeserializationError
          end
        when /^!ruby\/Mongoid:(.+)$/
          klass = resolve_class($1)
          payload = Hash[*object.children.map { |c| accept c }]
          begin
            klass.find(payload["attributes"]["_id"])
          rescue Mongoid::Errors::DocumentNotFound
            raise Delayed::DeserializationError
          end
        when /^!ruby\/DataMapper:(.+)$/
          klass = resolve_class($1)
          payload = Hash[*object.children.map { |c| accept c }]
          begin
            primary_keys = klass.properties.select { |p| p.key? }
            key_names = primary_keys.map { |p| p.name.to_s }
            klass.get!(*key_names.map { |k| payload["attributes"][k] })
          rescue DataMapper::ObjectNotFoundError
            raise Delayed::DeserializationError
          end
        else
          visit_Psych_Nodes_Mapping_without_class_and_db(object)
        end
      end
      alias_method_chain :visit_Psych_Nodes_Mapping, :class_and_db
    end
  end
end
