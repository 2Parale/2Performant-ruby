module TwoPerformant
  module Exceptions
    class Timeout < StandardError; end
    class ResourceTypeMismatch < StandardError
      def initialize(expected, got)
        super("Expected #{expected}, got #{got}")
      end
    end
  end
end
