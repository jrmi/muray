class Start

  create : ->
    console.log('Start state')

    @game.me.background = @game.add.sprite 0, 0, 'background'
    @game.me.background.inputEnabled = true
    @game.me.background.events.onInputDown.add ()=>
      @game.state.getCurrentState().inputCallback()


    @game.me.map1x1 = @game.add.tilemap('map')
    @game.me.map1x1.addTilesetImage('all', 'tileset')

    @game.me.layer2 = @game.me.map1x1.createBlankLayer('ground', 40, 30, 20, 20)
    @game.me.layer2.resizeWorld()
    @game.me.layer1 = @game.me.map1x1.createLayer('walls')
    @game.me.layer1.resizeWorld()

    @game.me.map1x1.currentLayer = 0


    @game.me.text = @game.add.text(@game.world.centerX, @game.world.centerY, '0', { font: "64px Arial", fill: "#ffffff", align: "center" })
    @game.me.text.anchor.setTo(0.5, 0.5)

    @game.me.fx = @game.add.audio('sfx')
    @game.me.fire = @game.add.audio('fire')


    @game.time.events.loop(Phaser.Timer.SECOND, () ->
      @game.state.getCurrentState().counterCallback()
    , this)


    @game.state.start 'main', false

    # TODO move callback better !!!!
    #game.input.addMoveCallback(updateMarker, this)

  inputCallback: ()->
      console.log('clique')




module.exports = Start
