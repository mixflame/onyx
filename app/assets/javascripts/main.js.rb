# put your main client side ruby game related scripts here

data_channel = nil

# UDP-like data channel message received
def data_channel_message(data)
  puts "Message received! #{data}"
end

# data channel is open and connected
def data_channel_open
  puts "Data channel open!"
  data_channel = $$.data_channel
  # send_message("ALIVE")
end

def send_message(msg)
  $$.send_message msg
end

# data channel is closed
def data_channel_closed
  puts "Data channel closed!"
end