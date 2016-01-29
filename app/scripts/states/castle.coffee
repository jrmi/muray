
class Castle

  create : ->
    @counter = 5
    @game.text.setText('' + @counter)

    @turnEnded = false
    @otherEnded = false
    @selected = null

    @marker = @game.add.sprite @game.layer1.getTileX(@game.input.x), @game.layer1.getTileX(@game.input.y), 'castleselect'
    @marker.anchor.setTo 0.5, 0.5

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

    first = []
    first.push(@addCastle(7, 5))
    @addCastle(8, 14)
    @addCastle(7, 23)

    first.push(@addCastle(29, 5))
    @addCastle(28, 14)
    @addCastle(29, 23)

    @selectCastle(first[@game.currentPlayer])

  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.text.setText('' + @counter)
      else
        @cleanState()
        @game.session.publish @game.prefix + 'turnEnded', ['castle', @game.currentPlayer]
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
    @game.text.setText('Place canon ...')

    if !@selected?
      @buildCastle(@currentCastle, @game.currentPlayer)
      @game.drop.play()

  update : ->
    if !@turnEnded and !@selected?
      if @game.currentPlayer == 0 and @game.input.x > 400
        return
      if @game.currentPlayer == 1 and @game.input.x < 400
        return

      p = new Phaser.Point()
      @game.layer1.getTileXY(@game.input.x, @game.input.y, p)
      for c in @game.castles
        if p.x >= c.x - 3 and p.x <= c.x + 3 and p.y >= c.y - 3 and p.y <= c.y + 3
          @selectCastle(c)
          return

  inputCallback: ()->
    if !@turnEnded and !@selected?
      @buildCastle(@currentCastle, @game.currentPlayer)
      @game.drop.play()

  moveCallback: ()->
    console.log('toto')

  selectCastle: (castle) ->
    @currentCastle = castle
    p2 = @game.XYTileToWorld(castle, @game.map1x1)
    @marker.x = p2.x + 20
    @marker.y = p2.y + 20

  buildCastle: (castle, player) ->
    @marker.destroy()
    @selected = castle
    blockList = []
    for x in [-3..4]
      for y in [-3..4]
        if (x==-3 or x==4) or (y==-3 or y==4)
          blockList.push({x:castle.x + x, y:castle.y + y})

    @game.buildTile(blockList, player)
    @game.session.publish @game.prefix + 'build', [blockList, @game.currentPlayer]

    @game.checkTerritory(player)

  addCastle: (x, y)->
    p = new Phaser.Point(x, y)
    castle = {x: p.x, y: p.y}

    @game.map1x1.putTile(@game.TILES.castle[0], p.x, p.y, 'objects')
    @game.map1x1.putTile(@game.TILES.castle[1], p.x + 1, p.y, 'objects')
    @game.map1x1.putTile(@game.TILES.castle[2], p.x, p.y + 1, 'objects')
    @game.map1x1.putTile(@game.TILES.castle[3], p.x + 1, p.y + 1, 'objects')

    @game.castles.push(castle)

    return castle

  onBuild: (args)->
    blockList = args[0]
    player = args[1]
    @game.buildTile(blockList, player)
    @game.checkTerritory(player)

module.exports = Castle

