require "active_support/xml_mini"
require "active_support/hash_with_indifferent_access"
require "active_support/core_ext/hash/conversions"

module Ebayr
  class StringWithAttributes < String
    def initialize(value, attributes)
      @attributes = attributes
      super(value)
    end
    def attributes
      @attributes || {}
    end
  end
end

module ActiveSupport
  class XMLConverter # :nodoc:
      def process_content(value)
        content = value["__content__"]
        if parser = ActiveSupport::XmlMini::PARSING[value["type"]]
          parser.arity == 1 ? parser.call(content) : parser.call(content, value)
        else
          Ebayr::StringWithAttributes.new(value["__content__"], ActiveSupport::HashWithIndifferentAccess.new(value))
        end
      end
  end
end

# -*- encoding : utf-8 -*-
module Ebayr #:nodoc:
  # A response to an Ebayr::Request.
  class Response < Record
    def initialize(request, response)
      ActiveSupport::XmlMini.backend = 'Nokogiri'
      @request = request
      @command = @request.command if @request
      @response = response
      @body = response.body if @response
      hash = self.class.from_xml(@body) if @body
      response_data = hash["#{@command}Response"] if hash
      super(response_data) if response_data
    end
  end
end
