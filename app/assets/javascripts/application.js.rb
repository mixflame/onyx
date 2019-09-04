require 'opal' # opal ruby compiler
require 'opal_ujs'
require 'turbolinks'
require 'p2' # p2 physics library
require 'pixi' # PixiJS (graphics)
require 'bump' # bumpjs (collision detection)
require 'cable' # action cable
require 'main' # your ruby game code lives here
require 'signaling-server' # webrtc unreliable datachannel signaling server
require 'native'
require 'js'

puts "Opal loaded."

VERSION = "0.0.2"
puts "Welcome to Azeroth Game Engine #{VERSION}"

# PixiJS setup

PIXI = $$.PIXI
type = "WebGL"
if !PIXI.utils.isWebGLSupported
  type = "canvas"
end

PIXI.utils.sayHello(type)

# application = Native(`PIXI.Application`)
# sprite = Native(`PIXI.Sprite`)
# text = Native(`PIXI.Text`)

`b = new Bump(PIXI)`
bump = $$.b
puts "Bump loaded, renderer: #{bump.renderer}"

`window.app = new PIXI.Application({width: 1024, height: 768, antialias: true})`
# app = $$.app
puts "PIXI app created"


# multi-key input. read the map variable for which keycodes are currently being pressed
map = {}
$$.onkeydown = -> (e) {
    `window.e = e`
    map[`window.e.keyCode`] = `e.type` == 'keydown'
    # puts "map: #{map}"
}
$$.onkeyup = -> (e) {
    `window.ef = e`
    map[`window.ef.keyCode`] = `ef.type` == 'keydown'
    # puts "map: #{map}"
}

# add your bodies and shapes here
`world = new p2.World();`

# floor
`planeShape = new p2.Plane();`
`planeBody = new p2.Body({ mass: 0, position:[0, -100] });`
$$.planeBody.addShape($$.planeShape)
$$.world.addBody($$.planeBody)

# handshake rigidbody
`circleBody = new p2.Body({mass: 1, position: [0, 200]});`
`circleShape = new p2.Circle({ radius: 1 });`
$$.circleBody.addShape($$.circleShape)
$$.world.addBody($$.circleBody)




# this callback fires the fixedUpdate in main.js.rb
$$.world.on 'postStep', -> (event) { fixedUpdate(event) }