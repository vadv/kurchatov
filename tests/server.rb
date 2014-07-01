require 'socket'
require 'timeout'
require 'kurchatov/riemann/client'
require 'yaml'
require_relative 'testreceived'

PORT = 5555
HOST = '127.0.0.1'
RECEIVE_INTERVAL = 60

server = TCPServer.new(HOST, PORT)
events = []
puts "Run riemann server at #{HOST}:#{PORT}"

Timeout::timeout(RECEIVE_INTERVAL) {
  client = server.accept
  loop do
    line = client.read(4)
    break if line.nil? || line.size != 4
    length = line.unpack('N').first
    str = client.read(length)
    message = Kurchatov::Riemann::Message.decode(str)
    message.events.each do |event|
      events << event
    end
  end
}

t = TestReceived.new(events, './tests/data/event.yml')
t.compare!
