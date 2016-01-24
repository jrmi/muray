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
    @game.checkTerritory(@game.currentPlayer)
    @game.checkTerritory(@game.otherPlayer)

    @turnEnded = false
    @otherEnded = false

    @counter = 10
    @game.text.setText('' + @counter)


  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.text.setText('' + @counter)
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
    @game.text.setText('Waiting...')
    @marker.destroy()
    for c in @cantbuilds
      c.destroy()


  updateMarker: ()->
    if @marker?
      @marker.destroy()

    @marker = @game.add.group(@game.layer1.getTileX(@game.input.x), @game.layer1.getTileX(@game.input.y), 'construct')

    shape = shapes[Math.floor(Math.random()*shapes.length)]
    for block in shape
      tile = @marker.create(20 * block[0], 20 * block[1], 'wall')
      tile.anchor.setTo 0.5, 0.5

    @marker.alpha = 0.4

  update : ->
    if !@turnEnded
      p = @game.XYWorldToTiledWorld(@game.input, @game.layer1)
      @marker.x = p.x + 10
      @marker.y = p.y + 10
      @checkOverlap()


  inputCallback: ()->
    if @game.input.activePointer.rightButton.isDown
      if @checkOverlap()

        blockList = []
        @marker.forEach (item) ->
          p = new Phaser.Point()
          @game.layer1.getTileXY(item.world.x, item.world.y, p)
          #blockList.push({x:Math.round(item.world.x), y: Math.round(item.world.y)})
          blockList.push(p)
        , this

        @game.buildTile(blockList, @game.currentPlayer)

        @game.drop.play()

        @game.session.publish @game.prefix + 'build', [blockList, @game.currentPlayer]

        @game.checkTerritory(@game.currentPlayer)
        @updateMarker()

    if @game.input.activePointer.leftButton.isDown
      @marker.rotation += Math.PI / 2

  onBuild: (args)->
    blockList = args[0]
    player = args[1]
    @game.buildTile(blockList, player)
    @game.checkTerritory(player)

  checkOverlap: ()->
    canbuild = true
    for c in @cantbuilds
      c.destroy()

    @marker.forEach (item) ->
      x = Math.round(item.world.x)
      y = Math.round(item.world.y)
      tile = @game.map1x1.getTileWorldXY(x, y)
      if tile and tile.index not in [@game.TILES.garbage, @game.TILES.house]
        canbuild = false
        c = @game.map1x1.game.add.sprite  x, y, 'cantbuild'
        c.alpha = 0.5
        c.anchor.setTo 0.5, 0.5
        @cantbuilds.push(c)
    , this

    return canbuild

module.exports = Repair
