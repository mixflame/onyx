# put your main client side ruby game related scripts here

# UDP-like data channel message received
def data_channel_message(data)
  puts "Message received! #{data}"
end

# data channel is open and connected
def data_channel_open
  puts "I'm alive!"
end

# data channel is closed
def data_channel_closed
  puts "I'm dead!"
end
