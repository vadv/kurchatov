require 'beefcake'
require 'kurchatov/riemann/event'

# monkey patch
module Beefcake::Message
  def initialize(attrs={})
    attrs ||= {}
    fields.values.each do |fld|
      self[fld.name] = attrs[fld.name]
    end
  end
end

module Kurchatov
  module Riemann
    class Message
      include Beefcake::Message

      optional :ok, :bool, 2
      optional :error, :string, 3
      repeated :events, Event, 6

      def encode_with_length
        buffer = ''
        encoded = encode buffer
        "#{[encoded.length].pack('N')}#{encoded}"
      end

    end
  end
end
