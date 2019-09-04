Welcome!

To begin:

```bundle install```

```rails s```

and navigate to http://localhost:3000

and on another machine, load http://your.ip:3000

Join the room on your local machine to become the host.

Join on the remote machine to become the client and receive interpolated physics updates.

All game code lives in assets/javascripts/main.js.rb

Application setup code lives in assets/javascripts/application.js.rb

Provided tools: Opal, Rails, Ruby, PixiJS, P2.js, Bump.js, signaling-server.js

Features:

Ruby on Rails backend with ActionCable and WebRTC
Opal frontend means you can use Ruby to write your client-side game code!
PixiJS with WebGL rendering for blazing fast 2D graphics in the browser
P2.js for lightweight 2d physics simulation
Bump.js included for non-physics based collision detection
Networked physics with interpolation over WebRTC UDP-like 2-way Data Channels
Use any database you want
Easily swap out the renderer or physics library for something else, the entire game engine is implemented in 2 files of Opal, main.js.rb and application.js.rb
Write web games in pure Ruby, not Javascript!