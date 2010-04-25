module TwoPerformant
  class Resource
    def self.resource_name
      @resource_name ||= self.name.underscore.gsub(/^[^\/]*\//,'')
    end

    def resource_name
      self.class.resource_name
    end
  end
end
