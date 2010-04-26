require 'date'
require 'yaml'
require 'bigdecimal'

module TwoPerformant
  # This is primarily based on ActiveSupport's conversions module
  module Caster
    XML_PARSING = {
      "symbol"       => Proc.new  { |symbol|  symbol.to_sym },
      "date"         => Proc.new  { |date|    ::Date.parse(date) },
      "datetime"     => Proc.new  { |time|    ::Time.parse(time).utc rescue ::DateTime.parse(time).utc },
      "integer"      => Proc.new  { |integer| integer.to_i },
      "float"        => Proc.new  { |float|   float.to_f },
      "decimal"      => Proc.new  { |number|  BigDecimal(number) },
      "boolean"      => Proc.new  { |boolean| %w(1 true).include?(boolean.strip) },
      "string"       => Proc.new  { |string|  string.to_s },
      "yaml"         => Proc.new  { |yaml|    YAML::load(yaml) rescue yaml },
    }

    XML_PARSING.update(
      "double"   => XML_PARSING["float"],
      "dateTime" => XML_PARSING["datetime"]
    )

    def self.typecast_xml_node(node)
      type = node.attributes['type'].value rescue nil
      is_nil = node.attributes['nil'].value == 'true' rescue nil
      value = node.children.first.text rescue nil

      return nil if is_nil

      if type == 'array'
        node.children.map do |child|
          klass = TwoPerformant::Resource.const_get(child.name.camelize)

          klass.new(child)
        end
      else
        if parser = XML_PARSING[type]
          XML_PARSING[type].call(value)
        else
          value
        end
      end
    end
  end
end
