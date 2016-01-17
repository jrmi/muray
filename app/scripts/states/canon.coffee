class Canon

  create : ->
    @marker = @game.add.sprite @game.me.layer1.getTileX(@game.input.x), @game.me.layer1.getTileX(@game.input.y), 'canon'
    @marker.alpha = 0.3
    @game.physics.arcade.enable(@marker);

    @counter = 3
    @game.me.text.setText('' + @counter)

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

  counterCallback : () ->
    @counter--
    @game.me.text.setText('' + @counter)
    if @counter <= 0
      for c in @game.me.cantbuilds
        c.destroy()
      @marker.destroy()
      @game.state.start 'fire', false

  update : ->
    @game.me.checkCanon(@game.input.x, @game.input.y)
    p = @game.me.XYWorldToTiledWorld(@game.input, @game.me.layer1)
    @marker.x = p.x
    @marker.y = p.y

  inputCallback: ()->
    if @game.me.checkCanon(@game.input.x, @game.input.y)
      @game.me.addCanon(@game.input.x, @game.input.y)
      @game.me.fx.play()



module.exports = Canon
