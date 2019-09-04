# put your main client side ruby game related scripts here

PIXI = $$.PIXI
loader = PIXI.loader
resources = PIXI.loader.resources

data_channel = nil

`window.remote_x = 0`
`window.remote_y = 0`
`window.local_x = 0`
`window.local_y = 0`

# UDP-like data channel message received
def data_channel_message(data)
  # puts "Message received! #{data}"
  if !$$.host
    receiveSync(data)
  end
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

# initial setup
def setup
  puts "Images loaded."
  zoom = 1000

  `window.renderer = PIXI.autoDetectRenderer()`
  # `window.container = new PIXI.Container()`

  # $$.app.stage.addChild($$.container)

  # $$.container.position.x =  $$.renderer.width/2
  # $$.container.position.y =  $$.renderer.height/2
  # $$.container.scale.x =  zoom
  # $$.container.scale.y = -zoom


  `window.handshake = new PIXI.Sprite(PIXI.loader.resources["handshake"].texture);`
  handshake = $$.handshake

  app = $$.app
  # container = $$.container
  handshake.x = 96 #app.screen.width / 2;
  handshake.y = 96 #app.screen.height / 2;
  handshake.scale.y = -1
  #handshake.anchor.x = 0.5;
  #handshake.anchor.y = 0.5;

  $$.app.stage.position.x =  $$.renderer.width/2
  $$.app.stage.position.y =  $$.renderer.height/2
  # $$.app.stage.scale.x =  zoom
  $$.app.stage.scale.y = -1

  app.stage.addChild(handshake)

  app.ticker.add { |delta| gameLoop(delta) }
end

def sendSync
  json = {x: $$.handshake.position.x, y: $$.handshake.position.y, rotation: $$.handshake.rotation}.to_json
  send_message json
end

def receiveSync(data)
  json = JSON.parse(data)
  # puts "receive sync: #{json}"
  # $$.handshake.position.x = json["x"]
  # $$.handshake.position.y = json["y"]
  # puts "handshake y: #{$$.handshake.position.y}"
  $$.remote_x = json["x"]
  $$.remote_y = json["y"]
  $$.local_x = $$.handshake.position.x
  $$.local_y = $$.handshake.position.y
  $$.handshake.rotation = json["rotation"]
end

def interpolate(deltaTime)
  x_difference = $$.remote_x - $$.local_x
  if (x_difference < 2)
      $$.handshake.position.x = $$.remote_x
  else
      $$.handshake.position.x += x_difference * deltaTime * 3
  end
  y_difference = $$.remote_y - $$.local_y
  if (y_difference < 2)
      $$.handshake.position.y = $$.remote_y
  else
      $$.handshake.position.y += y_difference * deltaTime * 3
  end
end

def gameLoop(delta)
  # game loop tick

  if !$$.host && $$.game_server_running
    interpolate(delta)
  end

  if $$.host && $$.game_server_running
    $$.world.step(1/60)

    $$.handshake.position.x = $$.circleBody.position[0]
    $$.handshake.position.y = $$.circleBody.position[1]
    $$.handshake.rotation = $$.circleBody.angle

    sendSync
  end
end

def fixedUpdate(event)
  # fixed update, called every physics step
end

Document.ready? do
  `document.body.appendChild(window.app.view)`
  loader.add("handshake", "/assets/handshake.png")
  loader.load { |loader, resources| setup }
end