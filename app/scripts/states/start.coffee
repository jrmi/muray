class Start

  create : ->
    console.log('player: ', @game.currentPlayer)
    @game.stage.disableVisibilityChange = true

    @game.me.background = @game.add.sprite 0, 0, 'background'
    @game.me.background.inputEnabled = true
    @game.me.background.events.onInputDown.add ()=>
      @game.state.getCurrentState().inputCallback()


    @game.me.map1x1 = @game.add.tilemap('map')
    @game.me.map1x1.addTilesetImage('all', 'tileset')

    @game.me.layer3 = @game.me.map1x1.createLayer('back')
    @game.me.layer3.resizeWorld()

    @game.me.layer2 = @game.me.map1x1.createLayer('secured')
    @game.me.layer2.resizeWorld()

    @game.me.layer1 = @game.me.map1x1.createLayer('objects')
    @game.me.layer1.resizeWorld()

    @game.me.map1x1.currentLayer = 2


    @game.me.text = @game.add.text(@game.world.centerX, @game.world.centerY, '0', { font: "64px Arial", fill: "#ffffff", align: "center" })
    @game.me.text.anchor.setTo(0.5, 0.5)

    @game.me.fx = @game.add.audio('sfx')
    @game.me.fire = @game.add.audio('fire')

    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      console.log('tic')
    , this)

    # TODO move callback better !!!!
    #game.input.addMoveCallback(updateMarker, this)

    if @game.currentPlayer == 1
      @game.session.publish @game.prefix + 'player2', [true]


  incomingPlayer2: (args)->
    console.log('Incomming')
    @game.session.publish @game.prefix + 'turnEnded', ['start', @game.currentPlayer]
    @game.state.start 'main', false

  onTurnEnded: (args) ->
    @game.state.start 'main', false

  inputCallback: ()->
      console.log('clic')




module.exports = Start
