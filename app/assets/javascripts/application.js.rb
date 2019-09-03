require 'opal'
require 'opal_ujs'
require 'turbolinks'
require 'pixi'
require 'bump'
require 'cable'
require 'main'
require 'signaling-server'
require 'native'
require 'js'

puts "Opal loaded."

VERSION = "0.0.1"
puts "Welcome to Azeroth Game Engine #{VERSION}"

# PixiJS setup

PIXI = $$.PIXI
type = "WebGL"
if !PIXI.utils.isWebGLSupported
  type = "canvas"
end

PIXI.utils.sayHello(type)

# application = Native(`PIXI.Application`)
loader = PIXI.loader
resources = PIXI.loader.resources
# sprite = Native(`PIXI.Sprite`)
# text = Native(`PIXI.Text`)

`b = new Bump(PIXI)`
bump = $$.b
puts "Bump loaded, renderer: #{bump.renderer}"

`window.app = new PIXI.Application({width: 1024, height: 768, antialias: true})`
# app = $$.app
puts "PIXI app created"

def setup
  puts "Images loaded."
  `window.handshake = new PIXI.Sprite(PIXI.loader.resources["handshake"].texture);`
  handshake = $$.handshake

  app = $$.app
  handshake.x = 96 #app.screen.width / 2;
  handshake.y = 96 #app.screen.height / 2;
  #handshake.anchor.x = 0.5;
  #handshake.anchor.y = 0.5;

  app.stage.addChild(handshake)
end

Document.ready? do
  `document.body.appendChild(window.app.view)`
  loader.add("handshake", "/assets/handshake.png")
  loader.load { |loader, resources| setup }
end



# how do I call javascript callbacks with args from Opal?
# def loadProgressHandler(loader, resource)
#     puts("loading: " + resource.url)
#     puts("progress: " + loader.progress + "%")
# end

