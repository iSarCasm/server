require 'socket'
s = UDPSocket.new

loop do
  s.send(gets.chomp, 0, '207.154.243.26', 44544)
  text, sender = s.recvfrom(1024)
  puts "Got UDP message: '#{text}' - from '#{sender}'"
end
