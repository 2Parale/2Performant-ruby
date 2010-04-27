module TwoPerformant
  module Resource
    class Base
      attr_accessor :node

      def self.resource_name
        # horrible pluralization, but it works for the classes that we're using
        #
        @resource_name ||= self.name.underscore.match(/(?:^|\/)([^\/]+)$/)[1] + 's'
      end

      def self.connection
        @connection ||= TwoPerformant::Connection.new(TwoPerformant.site)
      end

      def self.path
        "#{(@parent_path)}/#{self.resource_name}"
      end

      def self.all
        result = connection.get("#{path}.xml")
        if result.children[0].name == resource_name
          TwoPerformant::Caster.typecast_xml_node(result.children[0])
        end
      end

      def initialize(node = nil)
        @node = node
      end

      def connection
        self.class.connection
      end

      def resource_name
        self.class.resource_name
      end

      def method_missing(method, *args)
        xmlized_method = method.to_s.gsub(/_/,'-')

        found_node = node.at(xmlized_method.to_s)

        value = TwoPerformant::Caster.typecast_xml_node(found_node)

        if found_node
          (class << self; self; end).send(:define_method, method) do
            value rescue nil
          end

          value rescue nil
        else
          super
        end
      end

      def id
        return unless @node

        found_node = node.at('id')
        TwoPerformant::Caster.typecast_xml_node(found_node)
      end

      def get(id)
        result = connection.get("#{path_for(id)}.xml")
        if result.children[0].name == resource_name.chop
          @node = result.children[0]
        end
      end

      def path_for(id)
        "#{self.class.path}/#{id}"
      end

    end
  end
end
