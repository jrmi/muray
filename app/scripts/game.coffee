Phaser  = require 'phaser'
Autobahn  = require 'autobahn'
Map = require './classes/map'
Boot    = require './states/boot'
Preload = require './states/preload'
Menu    = require './states/menu'
Start    = require './states/start'
Main    = require './states/main'
Canon    = require './states/canon'
Fire    = require './states/fire'
Repair    = require './states/repair'


class Game extends Phaser.Game

  constructor : ->

    super 800, 600, Phaser.AUTO, 'game-content'

    @me = Map
    @me.game = this
    @state.add 'boot', Boot
    @state.add 'preload', Preload
    @state.add 'menu', Menu
    @state.add 'start', Start
    @state.add 'main', Main
    @state.add 'canon', Canon
    @state.add 'fire', Fire
    @state.add 'repair', Repair

    @state.start 'boot'


window.onload = ->

  uuid = window.location.hash.replace('#', '')

  conn = new Autobahn.Connection {
    url: 'ws://outils.youkidea.com:8787/ws',
    realm: 'realm1'
  }

  conn.onopen = (session) ->
    console.log('Wamp connection established')
    game = new Game()


    # Handle first or second player
    if uuid
      game.currentPlayer = 1
      game.otherPlayer = 0
    else
      uuid = 'test'
      game.currentPlayer = 0
      game.otherPlayer = 1

    game.session = session

    game.prefix = 'muray.' + uuid + '.'

    if game.currentPlayer == 0
      session.subscribe game.prefix + 'player2', (args) ->
        console.log('player2 is there ', args)
        console.log(game.state.getCurrentState())
        game.state.getCurrentState().incomingPlayer2(args)

    game.session.subscribe game.prefix + 'turnEnded', (args) ->
      console.log "Turn ended received", args
      if game.state.getCurrentState().onTurnEnded?
        game.state.getCurrentState().onTurnEnded(args)

    game.session.subscribe game.prefix + 'addCanon', (args) ->
      console.log "Add canon received", args
      if game.state.getCurrentState().onAddCanon?
        game.state.getCurrentState().onAddCanon(args)

    game.session.subscribe game.prefix + 'fire', (args) ->
      console.log "Fire received", args
      if game.state.getCurrentState().onFire?
        game.state.getCurrentState().onFire(args)

    game.session.subscribe game.prefix + 'build', (args) ->
      console.log "Build received", args
      if game.state.getCurrentState().onBuild?
        game.state.getCurrentState().onBuild(args)

    # Subscribe
    #session.subscribe('com.myapp.hello', onevent);

    # Publish
    #session.publish('com.myapp.hello', ['Hello, world!'])

    add2 = (args) ->
      return args[0] + args[1]

    #session.register('com.myapp.add2', add2);

    # Call
    #session.call('com.myapp.add2', [2, 3]).then (res) ->
    #     console.log("Result:", res)


    console.log('Connection opened')

  conn.onclose = (reason, details) ->
    console.log("Wamp connection closed")

  conn.open()