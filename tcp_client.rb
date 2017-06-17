require 'socket'
begin
  port = 44545
  client = TCPSocket.new('127.0.0.1', port)
  client.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1) # Nagle off
  loop do
    print "Input: "
    msg = gets.chomp
    client.puts(msg)
    response = client.gets
    puts "response = #{response}"
  end
ensure
  client.close if client
end
