class Start

  create : ->
    @game.stage.disableVisibilityChange = true

    @game.background = @game.add.sprite 0, 0, 'background'
    @game.background.inputEnabled = true

    @game.background.events.onInputDown.add ()=>
      if @game.state.getCurrentState().inputCallback?
        @game.state.getCurrentState().inputCallback()


    @game.map1x1 = @game.add.tilemap('map')
    @game.map1x1.addTilesetImage('all', 'tileset')

    @game.layer3 = @game.map1x1.createLayer('back')
    @game.layer3.resizeWorld()

    @game.layer2 = @game.map1x1.createLayer('secured')
    @game.layer2.resizeWorld()

    @game.layer1 = @game.map1x1.createLayer('objects')
    @game.layer1.resizeWorld()

    @game.map1x1.currentLayer = 2


    @game.text = @game.add.text(@game.world.centerX, @game.world.centerY, '0', { font: "64px Arial", fill: "#ffffff", align: "center" })
    @game.text.anchor.setTo(0.5, 0.5)

    @game.text.setText('Waiting for other...')

    @game.drop = @game.add.audio('drop')
    @game.fire = @game.add.audio('fire')
    @game.boum = @game.add.audio('boum')
    @game.secured = @game.add.audio('secure')
    @game.cantbuild = @game.add.audio('cantbuild')

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      console.log('tic')
    , this)

    # TODO move callback better !!!!
    #@game.input.addMoveCallback () ->

  update: ()->
    if @game.currentPlayer == 1
      @game.session.publish @game.prefix + 'player2', [true]
      @nextState()


  incomingPlayer2: (args)->
    console.log('Incomming')
    @nextState()

  nextState: () ->
    @game.state.start 'main', false


module.exports = Start
