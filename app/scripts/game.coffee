Phaser  = require 'phaser'
Autobahn  = require 'autobahn'
Boot    = require './states/boot'
Preload = require './states/preload'
Menu    = require './states/menu'
Start    = require './states/start'
Main    = require './states/main'
Castle    = require './states/castle'
Canon    = require './states/canon'
Fire    = require './states/fire'
Repair    = require './states/repair'
Victory    = require './states/victory'

uidChar = '12345679abcdefghjkmnpqrstuvwxyz'

wampPrefix = 'muray.'

class Game extends Phaser.Game

  TILES: {
    wall: 1
    walls:[1, 2]
    secured:[9, 10]
    garbage: 25
    house: 18
    tank: 17
    castle: [3, 4,11, 12]
    canon: [19, 20, 27, 28]
  }

  canons: []
  castles: []
  paired: false

  constructor : ->

    super 800, 600, Phaser.AUTO, 'game-content'

    @state.add 'boot', Boot
    @state.add 'preload', Preload
    @state.add 'menu', Menu
    @state.add 'start', Start
    @state.add 'main', Main
    @state.add 'castle', Castle
    @state.add 'canon', Canon
    @state.add 'fire', Fire
    @state.add 'repair', Repair
    @state.add 'victory', Victory

    @state.start 'boot'

  reset: ()->
    for c in @canons
      c.destroy()
    @canons = []
    @castles = []

  genUid: (length=5) ->
    uid = ""
    for x in [0..length]
      uid += @pick uidChar

    return uid

  rand: (min, max) ->
    Math.random() * (max - min) + min

  randint: (min, max) ->
    Math.round(@rand(min, max))

  pick: (list) ->
    return list[@randint(0, list.length - 1)]

  XYTileToWorld2: (p, map)->
    p.x = p.x * map.tileWidth + Math.round(map.tileWidth / 2)
    p.y = p.y * map.tileWidth + Math.round(map.tileHeight / 2)
    return p

  XYTileToWorld: (p, map)->
    p2 = new Phaser.Point()
    p2.x = p.x * map.tileWidth
    p2.y = p.y * map.tileWidth
    return p2

  XYWorldToTiledWorld: (point, layer)->
    p = new Phaser.Point()
    layer.getTileXY(point.x, point.y, p)
    p = @XYTileToWorld(p, layer.map)
    return  p

  build: (blockList, player) ->
    for block in blockList
      @map1x1.putTileWorldXY(@TILES.walls[player], block.x, block.y, 20, 20, 'objects')

  buildTile: (blockList, player) ->
    for block in blockList
      @map1x1.putTile(@TILES.walls[player], block.x, block.y, 'objects')

  countCastle: (player)->
    count = 0
    for c in @castles
      t = @map1x1.getTile(c.x, c.y, 'secured')
      if t? and t.index == @TILES.secured[player]
        count++

    return count


  floodFill: (map, x, y, source, dest) ->
    if map[x][y] != source
      return

    map[x][y] = dest

    for i in [x-1..x+1]
      for j in [y-1..y+1]
        if i >= 0 and i <= 41 and j >=0 and j <= 31
          @floodFill(map, i, j, source, dest)

  checkTerritory: (player) ->
    table = []
    for x in [0..43]
      line = []
      for y in [0..33]
        if x == 0 || x == 43 || y == 0 || y == 33
          res = 1
        else
          if x == 1 || x == 42 || y == 1 || y == 32
            res = 0
          else
            tile = @map1x1.getTile(x - 2, y - 2, 'objects')
            res = 0
            if tile? and tile.index == @TILES.walls[player]
              res = 1
        line.push(res)
      table.push(line)

    @floodFill(table, 1, 1, 0, 2)

    secured = false

    for x in [0..39]
      for y in [0..29]

        if table[x + 2][y + 2] == 0
          t = @TILES.secured[player]
        else
          t = null

        cur = @map1x1.getTile(x, y, 'secured')
        if t == null and cur? and cur.index == @TILES.secured[player] or t != null and !cur?
          if t != null and cur == null
            secured = true
          @map1x1.putTile(t, x, y, 'secured')

    return secured

window.onload = ->

  hashUid = window.location.hash.replace('#', '')

  conn = new Autobahn.Connection {
    url: 'ws://outils.youkidea.com:8787/ws',
    realm: 'realm1'
  }

  conn.onopen = (session) ->
    console.log('Wamp connection established')
    game = new Game()

    game.myUid = game.genUid()

    game.session = session

    game.prefix = wampPrefix + game.myUid + '.'

    console.log('Game object created')

    subscribeGameEvents = (game) ->

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

      game.session.subscribe game.prefix + 'restart', (args) ->
        console.log "Restart received", args
        game.reset()
        game.state.start 'menu', true

    game.session.subscribe wampPrefix + 'newPlayer', (args) ->
      if not game.paired
        console.log "newPlayer received", args

        otherUid = args[0]
        session.call(wampPrefix + otherUid + '.join', [game.myUid]).then (res) ->
          console.log('Call join result', res)
          if res is null
            return

          game.paired = true
          game.prefix = wampPrefix + otherUid + '.'

          if res == 1
            game.currentPlayer = 1
            game.otherPlayer = 0
          if res == 0
            game.currentPlayer = 0
            game.otherPlayer = 1

          subscribeGameEvents(game)

    game.session.register wampPrefix + game.myUid + '.join', (args) ->
      if not game.paired
        console.log('Paired with ' + args[0])
        game.paired = true
        game.prefix = wampPrefix + game.myUid + '.'

        res = game.pick([0,1])
        if res == 1
          game.currentPlayer = 0
          game.otherPlayer = 1
        if res == 0
          game.currentPlayer = 1
          game.otherPlayer = 0

        subscribeGameEvents(game)

        return res
      else
        return null

    game.session.publish(wampPrefix + 'newPlayer', [game.myUid])



    console.log('Connection opened')

  conn.onclose = (reason, details) ->
    console.log("Wamp connection closed")

  conn.open()