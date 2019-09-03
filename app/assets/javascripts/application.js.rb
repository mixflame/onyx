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

application = Native(`PIXI.Application`)
loader = PIXI.loader
resources = PIXI.loader.resources
sprite = Native(`PIXI.Sprite`)
text = Native(`PIXI.Text`)

`b = new Bump(PIXI)`
bump = $$.b
puts "Bump loaded, renderer: #{bump.renderer}"

`window.app = new PIXI.Application({width: 1280, height: 690, antialias: true})`
app = $$.app
puts "PIXI app created: #{app}"

Document.ready? do
  `document.body.appendChild(window.app.view)`
end
