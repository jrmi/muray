class Repair

  shapes = [
    [[0,0], [1,0], [-1,0]],
    [[0,0], [1,0]],
    [[0,0], [1,0], [-1,0], [1,1]],
    [[0,0], [1,0], [-1,0], [-1,-1]],
    [[0,0], [1,0], [-1,0], [0,1]],
    [[0,0], [1,0], [0,1]],
    [[0,0], [0,-1], [0,1], [1,-1],[1,1]],
  ]

  create : ->
    @game.stage.disableVisibilityChange = true
    @cantbuilds = []


    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

    @updateMarker()
    @checkTerritory(@game.currentPlayer)
    @checkTerritory(@game.otherPlayer)

    @turnEnded = false
    @otherEnded = false

    @counter = 10
    @game.me.text.setText('' + @counter)


  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.me.text.setText('' + @counter)
      else
        @cleanState()
        @game.session.publish @game.prefix + 'turnEnded', ['repair', @game.currentPlayer]
        if !@otherEnded
          @turnEnded = true
        else
          @nextState()

  onTurnEnded: (args) ->
    if @turnEnded
      @nextState()
    else
      @otherEnded = true

  nextState: ()->
    @game.state.start 'canon', false

  cleanState: ()->
    @game.me.text.setText('waiting')
    @marker.destroy()
    for c in @cantbuilds
      c.destroy()


  updateMarker: ()->
    if @marker?
      @marker.destroy()

    @marker = @game.add.group(@game.me.layer1.getTileX(@game.input.x), @game.me.layer1.getTileX(@game.input.y), 'construct')

    shape = shapes[Math.floor(Math.random()*shapes.length)]
    for block in shape
      tile = @marker.create(20 * block[0], 20 * block[1], 'wall')
      tile.anchor.setTo 0.5, 0.5

    @marker.alpha = 0.4

  update : ->
    if !@turnEnded
      p = @game.me.XYWorldToTiledWorld(@game.input, @game.me.layer1)
      @marker.x = p.x + 10
      @marker.y = p.y + 10
      @checkOverlap()


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
            tile = @game.me.map1x1.getTile(x - 2, y - 2, 'objects')
            res = 0
            if tile? and tile.index == @game.me.TILES.walls[player]
              res = 1
        line.push(res)
      table.push(line)

    @floodFill(table, 1, 1, 0, 2)

    for x in [0..40]
      for y in [0..30]

        if table[x + 2][y + 2] == 0
          t = @game.me.TILES.secured[player]
        else
          t = null

        cur = @game.me.map1x1.getTile(x, y, 'secured')
        if !cur? or cur.index == @game.me.TILES.secured[player]
          @game.me.map1x1.putTile(t, x, y, 'secured')


  inputCallback: ()->
    if @game.input.activePointer.leftButton.isDown
      if @checkOverlap()
        blockList = []
        @marker.forEach (item) ->
          blockList.push({x:Math.round(item.world.x), y: Math.round(item.world.y)})
        , this
        @build(blockList, @game.currentPlayer)
        #@marker.forEach (item) ->
        #  @game.me.map1x1.putTileWorldXY(@game.me.TILES.wall[@game.currentPlayer], Math.round(item.world.x), Math.round(item.world.y), 20, 20, 'objects')
        #, this
        @game.me.fx.play()
        @checkTerritory(@game.currentPlayer)
        @updateMarker()
        @game.session.publish @game.prefix + 'build', [blockList, @game.currentPlayer]

    if @game.input.activePointer.rightButton.isDown
      @marker.rotation += Math.PI / 2

  onBuild: (args)->
    blockList = args[0]
    player = args[1]
    @build(blockList, player)
    @checkTerritory(player)


  build: (blockList, player) ->
    for block in blockList
      @game.me.map1x1.putTileWorldXY(@game.me.TILES.walls[player], block.x, block.y, 20, 20, 'objects')

  checkOverlap: ()->
    canbuild = true
    for c in @cantbuilds
      c.destroy()

    @marker.forEach (item) ->
      x = Math.round(item.world.x)
      y = Math.round(item.world.y)
      tile = @game.me.map1x1.getTileWorldXY(x, y)
      if tile and tile.index not in [@game.me.TILES.garbage, @game.me.TILES.house]
        canbuild = false
        c = @game.me.map1x1.game.add.sprite  x, y, 'cantbuild'
        c.alpha = 0.5
        c.anchor.setTo 0.5, 0.5
        @cantbuilds.push(c)
    , this

    return canbuild

module.exports = Repair
