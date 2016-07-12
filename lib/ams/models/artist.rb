module Ams
  module Models
    class Artist

      attr_accessor :name, :am_id
      attr_reader :url_part

      def url_part= _url_part
        @am_id = _url_part.nil? ? nil : _url_part.split('-').last
        @url_part = _url_part
      end

      def to_hash
        instance_variables.inject({}) do |hsh, var|
          hsh[var[1..-1].to_sym] = instance_variable_get(var)
          hsh
        end
      end

    end
  end
end
