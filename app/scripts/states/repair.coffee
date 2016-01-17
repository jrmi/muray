class Repair

  shapes = [
    [[0,0], [1,0], [-1,0]],
    [[0,0], [1,0]],
    [[0,0], [1,0], [-1,0], [1,1]],
    [[0,0], [1,0], [-1,0], [0,1]],
    [[0,0], [1,0], [0,1]],
    [[0,0], [0,-1], [0,1], [1,-1],[1,1]],
  ]

  create : ->

    @cantbuilds = []
    @counter = 10
    @game.me.text.setText('' + @counter)


    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

    @updateMarker()
    @checkTerritory()

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
    p = @game.me.XYWorldToTiledWorld(@game.input, @game.me.layer1)
    @marker.x = p.x + 10
    @marker.y = p.y + 10
    @checkOverlap()

  counterCallback : () ->
    @counter--
    @game.me.text.setText('' + @counter)
    if @counter <= 0
      @marker.destroy()
      for c in @cantbuilds
        c.destroy()
      @game.state.start 'canon', false


  floodFill: (map, x, y, source, dest) ->
    if map[x][y] != source
      return

    map[x][y] = dest

    for i in [x-1..x+1]
      for j in [y-1..y+1]
        if i >= 0 and i <= 41 and j >=0 and j <= 31
          @floodFill(map, i, j, source, dest)

  checkTerritory: () ->
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
            tile = @game.me.map1x1.getTile(x - 2, y - 2)
            res = 0
            if tile? and tile.index == 1
              res = 1
        line.push(res)
      table.push(line)

    @floodFill(table, 1, 1, 0, 2)

    for x in [0..40]
      for y in [0..30]

        if table[x + 2][y + 2] == 0
          t = @game.me.TILES.garbage
        else
          t = null

        @game.me.map1x1.putTile(t, x, y, 'ground')


  inputCallback: ()->
    if @game.input.activePointer.leftButton.isDown
      if @checkOverlap()
        @marker.forEach (item) ->
          @game.me.map1x1.putTileWorldXY(@game.me.TILES.wall, Math.round(item.world.x), Math.round(item.world.y), 20, 20, 'walls')
        , this
        @game.me.fx.play()
        @checkTerritory()
        @updateMarker()

    if @game.input.activePointer.rightButton.isDown
      @marker.rotation += Math.PI / 2

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
