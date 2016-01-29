class Canon

  create : ->
    @game.stage.disableVisibilityChange = true

    @cantbuilds= []

    @turnEnded = false
    @otherEnded = false

    @counter = 5

    @maxCanon = 1 + @game.countCastle(@game.currentPlayer)

    @started = false
    @game.text.alpha = 0.1
    @game.text.setText('Place your cannons !')

    appear = @game.add.tween(@game.text).to( { alpha: 1 }, 200, "Linear", true)

    appear.onComplete.add () ->
      @game.time.events.add Phaser.Timer.SECOND * 2, () ->
        disappear = @game.add.tween(@game.text).to( { alpha: 0.1 }, 200, "Linear", true)
        disappear.onComplete.add () ->
          @started = true
          @game.text.setText('' + @counter)
          @game.text.alpha = 1
          @startState()
        , this
      , this
    , this


  startState: ()->
    @marker = @game.add.sprite @game.layer1.getTileX(@game.input.x), @game.layer1.getTileX(@game.input.y), 'canon'
    @marker.alpha = 0.6

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.text.setText('' + @counter)
      else
        @cleanState()
        @game.session.publish @game.prefix + 'turnEnded', ['canon', @game.currentPlayer]
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
    @game.state.start 'fire', false

  cleanState: ()->
    @game.text.setText('')

    for c in @cantbuilds
      c.destroy()
    @marker.destroy()

  update : ->
    if @started and !@turnEnded and @maxCanon > 0
      p = @correctedInput()
      @checkCanon(p.x, p.y, @game.currentPlayer)
      p = @game.XYWorldToTiledWorld(p, @game.layer1)
      @marker.x = p.x
      @marker.y = p.y

  correctedInput: ()->
    return new Phaser.Point(@game.input.x - 10, @game.input.y - 10)

  inputCallback: ()->
    if @started and !@turnEnded and @maxCanon > 0
      p = @correctedInput()
      if @checkCanon(p.x, p.y, @game.currentPlayer)
        @addCanon(p.x, p.y)
        @game.session.publish @game.prefix + 'addCanon', [p.x, p.y, @game.currentPlayer]
        @game.drop.play()
        @maxCanon--

        if @maxCanon < 1
          @marker.visible = false
      else
        @game.cantbuild.play()

  onAddCanon: (args) ->
    @addCanon(args[0], args[1])

  addCanon: (x, y)->
    p = new Phaser.Point()
    @game.layer1.getTileXY(x,y, p)

    mapCoord = {x: p.x, y: p.y}

    @game.map1x1.putTile(@game.TILES.canon[0], p.x, p.y, 'objects')
    @game.map1x1.putTile(@game.TILES.canon[1], p.x + 1, p.y, 'objects')
    @game.map1x1.putTile(@game.TILES.canon[2], p.x, p.y + 1, 'objects')
    @game.map1x1.putTile(@game.TILES.canon[3], p.x + 1, p.y + 1, 'objects')

    p = @game.XYTileToWorld(p, @game.map1x1)

    canon = @game.map1x1.game.add.sprite p.x + 20, p.y + 20, 'canon'
    canon.anchor.setTo 0.5, 0.5
    canon.mapCoord = mapCoord
    @game.canons.push(canon)

  checkCanon: (x, y, player)->
    canbuild = true
    for c in @cantbuilds
      c.destroy()

    p = new Phaser.Point()
    @game.layer1.getTileXY(x, y, p)

    for xx in [p.x, p.x + 1]
      for yy in [p.y, p.y + 1]
        secure = @game.map1x1.getTile(xx, yy, 'secured')
        if @game.map1x1.getTile(xx, yy, 'objects') or !(secure? and secure.index == @game.TILES.secured[player])
          canbuild = false
          c = @game.map1x1.game.add.sprite  xx * 20, yy * 20, 'cantbuild'
          c.alpha = 0.7
          @cantbuilds.push(c)

    return canbuild



module.exports = Canon
