# put your main client side ruby game related scripts here

PIXI = $$.PIXI
loader = PIXI.loader
resources = PIXI.loader.resources

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
  #handshake.anchor.x = 0.5;
  #handshake.anchor.y = 0.5;

  $$.app.stage.position.x =  $$.renderer.width/2
  $$.app.stage.position.y =  $$.renderer.height/2
  # $$.app.stage.scale.x =  zoom
  $$.app.stage.scale.y = -1

  app.stage.addChild(handshake)

  app.ticker.add { |delta| gameLoop(delta) }
end

def gameLoop(delta)
  # game loop tick


  $$.world.step(1/60)

  $$.handshake.position.x = $$.circleBody.position[0]
  $$.handshake.position.y = $$.circleBody.position[1]
  $$.handshake.rotation = $$.circleBody.angle
end

def fixedUpdate(event)
  # fixed update, called every physics step
end

Document.ready? do
  `document.body.appendChild(window.app.view)`
  loader.add("handshake", "/assets/handshake.png")
  loader.load { |loader, resources| setup }
end