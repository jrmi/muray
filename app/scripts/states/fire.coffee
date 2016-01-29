class Fire

  create : ->
    @game.stage.disableVisibilityChange = true
    @marker = @game.add.sprite @game.layer1.getTileX(@game.input.x), @game.layer1.getTileX(@game.input.y), 'notready'

    @currentCanon = 0

    @myCanons = []
    for c in @game.canons
      secure = @game.map1x1.getTile(c.mapCoord.x, c.mapCoord.y, 'secured')
      if secure? and secure.index == @game.TILES.secured[@game.currentPlayer]
        @myCanons.push(c)

    @turnEnded = false
    @otherEnded = false

    @fireing = 0
    @counter = 10

    @started = false
    @game.text.alpha = 0.1
    @game.text.setText('Prepare for battle !')

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
    @marker.destroy()
    @marker = @game.add.sprite @game.layer1.getTileX(@game.input.x), @game.layer1.getTileX(@game.input.y), 'crosshair'


    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)


  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.text.setText('' + @counter)
      else
        @game.text.setText('Cease fire !')
        @cleanState()
        # wait for all shot to finish
        if @fireing > 0
          return

        @game.session.publish @game.prefix + 'turnEnded', ['fire', @game.currentPlayer]
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
    @game.state.start 'repair', false

  cleanState: ()->
    @marker.destroy()

  update : ->
    if !@turnEnded
      @marker.x = @game.input.x - 15
      @marker.y = @game.input.y - 15

    for canon in @myCanons
      canon.rotation = @game.physics.arcade.angleBetween(canon, @game.input) + Math.PI / 2

  inputCallback: () ->
    if @started and @myCanons.length and @counter > 0
      canon = @myCanons[@currentCanon]
      if not canon.busy
        canon.busy = true

        @currentCanon++
        if @currentCanon >= @myCanons.length
          @currentCanon = 0


        @fire canon, {x: @game.input.x, y: @game.input.y}, ->
          canon.busy = false
        @game.session.publish @game.prefix + 'fire', [{x: canon.x, y:canon.y}, {x: @game.input.x, y: @game.input.y}]

  onFire: (args)->
    @fire(args[0], args[1])

  fire: (src, dest, endCallback=->) ->
    @fireing++
    @game.fire.play()
    shot = @game.add.sprite  src.x, src.y, 'shot'
    shot.anchor.setTo 0.5, 0.5
    shot.scale.x = 0.5
    shot.scale.y = 0.5

    distance = Math.sqrt(Math.pow((src.x - dest.x), 2) + Math.pow((src.y - dest.y), 2))
    time = distance * 10

    shotted = @game.add.tween(shot)
    scaled = @game.add.tween(shot.scale)

    shotted.to({ x: dest.x, y: dest.y }, time, Phaser.Easing.Quartic.InOut)
    scaled.to({ x: 1 + distance / 200, y: 1 + distance / 200 }, time / 2, Phaser.Easing.Cubic.In)

    shotted.onComplete.add () ->
      tile = @game.map1x1.getTileWorldXY(dest.x, dest.y, 20, 20, 'objects')
      if tile? and tile.index in @game.TILES.walls
        @game.map1x1.putTileWorldXY(@game.TILES.garbage, dest.x, dest.y, 20, 20, 'objects')
        @game.boum.play()
      shot.destroy()
      @fireing--
      endCallback()
    , this

    scaled.onComplete.add () ->
      scaledDown = @game.add.tween(shot.scale)
      scaledDown.to({ x: 0.5, y: 0.5 }, time / 2, Phaser.Easing.Cubic.Out)
      scaledDown.start()
    , this

    scaled.start()
    shotted.start()


module.exports = Fire
