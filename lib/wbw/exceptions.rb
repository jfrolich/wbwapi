module Wbw
  module Exceptions
    class Exception < RuntimeError
      attr_accessor :response_code, :message

      def initialize response_code = nil, message = nil
        @response_code = response_code
        @message = message
      end

      def inspect
        "#{response_code}: #{message}"
      end

      def to_s
        inspect
      end

      def message
        @message || self.class.name
      end
    end

    class Unauthorized < Exception
      def initialize
        super 401, "Unauthorized!"
      end
    end 
  end
end
