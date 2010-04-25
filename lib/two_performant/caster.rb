module TwoPerformant
  # This is primarily based on ActiveSupport's conversions module
  module Caster
    XML_TYPE_NAMES = {
      "Symbol"     => "symbol",
      "Fixnum"     => "integer",
      "Bignum"     => "integer",
      "BigDecimal" => "decimal",
      "Float"      => "float",
      "TrueClass"  => "boolean",
      "FalseClass" => "boolean",
      "Date"       => "date",
      "DateTime"   => "datetime",
      "Time"       => "datetime",
      "ActiveSupport::TimeWithZone" => "datetime"
    } unless defined?(XML_TYPE_NAMES)

    XML_FORMATTING = {
      "symbol"   => Proc.new { |symbol| symbol.to_s },
      "date"     => Proc.new { |date| date.to_s(:db) },
      "datetime" => Proc.new { |time| time.xmlschema },
      "yaml"     => Proc.new { |yaml| yaml.to_yaml }
    } unless defined?(XML_FORMATTING)

    # TODO: use Time.xmlschema instead of Time.parse;
    #       use regexp instead of Date.parse
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

    def typecast_xml_node(node)
      type = node.attributes['type'].value rescue nil
      case value.class.to_s
        when 'Hash'
          if value['type'] == 'array'
            child_key, entries = value.detect { |k,v| k != 'type' }   # child_key is throwaway
            if entries.nil? || (c = value['__content__'] && c.blank?)
              []
            else
              case entries.class.to_s   # something weird with classes not matching here.  maybe singleton methods breaking is_a?
              when "Array"
                entries.collect { |v| typecast_xml_value(v) }
              when "Hash"
                [typecast_xml_value(entries)]
              else
                raise "can't typecast #{entries.inspect}"
              end
            end
          elsif value.has_key?("__content__")
            content = value["__content__"]
            if parser = XML_PARSING[value["type"]]
              if parser.arity == 2
                XML_PARSING[value["type"]].call(content, value)
              else
                XML_PARSING[value["type"]].call(content)
              end
            else
              content
            end
          elsif value['type'] == 'string' && value['nil'] != 'true'
            ""
          # blank or nil parsed values are represented by nil
          elsif value.blank? || value['nil'] == 'true'
            nil
          # If the type is the only element which makes it then 
          # this still makes the value nil, except if type is
          # a XML node(where type['value'] is a Hash)
          elsif value['type'] && value.size == 1 && !value['type'].is_a?(::Hash)
            nil
          else
            xml_value = value.inject({}) do |h,(k,v)|
              h[k] = typecast_xml_value(v)
              h
            end
            
            # Turn { :files => { :file => #<StringIO> } into { :files => #<StringIO> } so it is compatible with
            # how multipart uploaded files from HTML appear
            xml_value["file"].is_a?(StringIO) ? xml_value["file"] : xml_value
          end
        when 'Array'
          value.map! { |i| typecast_xml_value(i) }
          case value.length
            when 0 then nil
            when 1 then value.first
            else value
          end
        when 'String'
          value
        else
          raise "can't typecast #{value.class.name} - #{value.inspect}"
      end
    end
  end
end
