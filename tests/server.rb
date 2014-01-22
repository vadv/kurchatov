require "socket"
require "timeout"

server = TCPServer.new('127.0.0.1', 5555)
Timeout::timeout(60) {
  loop {
    client = server.accept
    line = client.gets
    puts line
  }
} rescue exit 0
