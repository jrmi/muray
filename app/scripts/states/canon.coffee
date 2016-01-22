class Canon

  create : ->
    @game.stage.disableVisibilityChange = true
    @marker = @game.add.sprite @game.me.layer1.getTileX(@game.input.x), @game.me.layer1.getTileX(@game.input.y), 'canon'
    @marker.alpha = 0.3

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @counterCallback()
    , this)

    @turnEnded = false
    @otherEnded = false

    @counter = 5
    @game.me.text.setText('' + @counter)

  counterCallback : () ->
    if !@turnEnded
      if @counter > 0
        @counter--
        @game.me.text.setText('' + @counter)
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
    @game.me.text.setText('waiting')

    for c in @game.me.cantbuilds
      c.destroy()
    @marker.destroy()

  update : ->
    if !@turnEnded
      @game.me.checkCanon(@game.input.x, @game.input.y)
      p = @game.me.XYWorldToTiledWorld(@game.input, @game.me.layer1)
      @marker.x = p.x
      @marker.y = p.y

  inputCallback: ()->
    if @game.me.checkCanon(@game.input.x, @game.input.y)
      @game.me.addCanon(@game.input.x, @game.input.y)
      @game.me.fx.play()





module.exports = Canon
