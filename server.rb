class Server
  attr_reader :last
  def initialize
    @last = 1
  end

  def think
    @last = Time.now
  end
end

server = Server.new

require 'socket'
require 'eventmachine'
Thread::abort_on_exception = true
# UDP
s = UDPSocket.new
s.bind('0.0.0.0', 44544)

Thread.start do
  loop do
    text, sender = s.recvfrom(1024)
    puts "Got UDP message: '#{text}' - from '#{sender}'"
    s.send(server.last.to_s, 0, sender[2], sender[1])
  end
end
# TCP
PORT = 44545
puts "Listening on #{PORT}...\n"

class EchoServer < EM::Connection
  def initialize(server)
    @server = server
  end

  def receive_data(data)
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    puts "Got TCP message: '#{data.chomp}' - from '#{ip}:#{port}'"
    send_data "(#{@server.last}) #{data}"
    close_connection if data == 'quit'
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
   end
end

EventMachine.run do
  Signal.trap("INT")  { EventMachine.stop }
  Signal.trap("TERM") { EventMachine.stop }
  EventMachine.start_server("0.0.0.0", PORT, EchoServer, server)
  EM.add_periodic_timer(0.05) { server.think }
end
