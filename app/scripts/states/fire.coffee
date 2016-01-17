class Fire

  create : ->
    @marker = @game.add.sprite @game.me.layer1.getTileX(@game.input.x), @game.me.layer1.getTileX(@game.input.y), 'crosshair'

    @counter = 2
    @game.me.text.setText('' + @counter)

    @currentCanon = 0

    @canfire = true

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

  update : ->
    @marker.x = @game.input.x - 15
    @marker.y = @game.input.y - 15
    for canon in @game.me.canons
      canon.rotation = @game.physics.arcade.angleBetween(canon, @game.input) + Math.PI / 2

  counterCallback : () ->
    if @canfire
      @counter--
      @game.me.text.setText('' + @counter)
      if @counter <= 0
        @canfire = false
    else
      for c in @game.me.canons
        if c.busy
          return

      @marker.destroy()
      @game.state.start 'repair', false

  inputCallback: () ->
    if @game.me.canons.length and @canfire
      canon = @game.me.canons[@currentCanon]
      if not canon.busy
        currentX = @game.input.x
        currentY = @game.input.y
        canon.busy = true

        @currentCanon++
        if @currentCanon >= @game.me.canons.length
          @currentCanon = 0
        @game.me.fire.play()

        shot = @game.add.sprite  canon.x, canon.y, 'shot'
        shot.anchor.setTo 0.5, 0.5
        shot.scale.x = 0.5
        shot.scale.y = 0.5

        distance = Math.sqrt(Math.pow((canon.x - currentX), 2) + Math.pow((canon.y - currentY), 2))
        time = distance * 10

        shotted = @game.add.tween(shot)
        scaled = @game.add.tween(shot.scale)

        shotted.to({ x: @game.input.x, y: @game.input.y }, time, Phaser.Easing.Quartic.InOut)
        scaled.to({ x: 1 + distance / 200, y: 1 + distance / 200 }, time / 2, Phaser.Easing.Cubic.In)

        shotted.onComplete.add () ->
          canon.busy = false
          tile = @game.me.map1x1.getTileWorldXY(currentX, currentY)
          if tile? and tile.index == @game.me.TILES.wall
            @game.me.map1x1.putTileWorldXY(@game.me.TILES.garbage, currentX, currentY, 20, 20, 'walls')
          shot.destroy()
        , this

        scaled.onComplete.add () ->
          scaledDown = @game.add.tween(shot.scale)
          scaledDown.to({ x: 0.5, y: 0.5 }, time / 2, Phaser.Easing.Cubic.Out)
          scaledDown.start()
        , this

        scaled.start()
        shotted.start()


  endShot: (arg) ->
    console.log arg

module.exports = Fire
