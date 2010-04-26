module TwoPerformant
  module Resource
    class Base
      attr_accessor :node

      def self.resource_name
        @resource_name ||= self.name.underscore.match(/(?:^|\/)([^\/]+)$/)[1]
      end

      def initialize(node = nil)
        @node = node
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
    end
  end
end
