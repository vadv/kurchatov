require 'socket'
require 'timeout'
require 'kurchatov/riemann/client'
require 'yaml'

PORT = 5555
HOST = '127.0.0.1'
server = TCPServer.new(HOST, PORT)
events = []
puts "Run riemann server at #{HOST}:#{PORT}"

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

data = YAML.load_file('./tests/data/event.yml')
events.each do |e|
  data["events"].each do |d|
    next unless d[:service] == e[:service]
    next if d[:result] == e[:state]
    raise "Recieved state: #{e[:state]}, data state: #{d[:result]}"
  end
end

raise "Not all events recieved" unless 3 * data["events"].count == events.count
puts "All done!"
