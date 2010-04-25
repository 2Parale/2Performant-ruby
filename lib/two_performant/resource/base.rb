module TwoPerformant
  module Resource
    class Base
      attr_accessor :node

      def self.resource_name
        @resource_name ||= self.name.underscore.match(/(?:^|\/)([^\/]+)$/)[1]
      end

      def resource_name
        self.class.resource_name
      end

      def method_missing(method, *args)
        xmlized_method = method.to_s.gsub(/_/,'-')

        found_node = node.at(xmlized_method.to_s)

        if found_node
          (class << self; self; end).send(:define_method, method) do
            found_node.children.first.text rescue nil
          end

          found_node.children.first.text rescue nil
        else
          super
        end
      end
    end
  end
end
