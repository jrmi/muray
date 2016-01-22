class Preload

  preload: ->

    loadingBar = @add.sprite 400, 300, 'preloader'
    loadingBar.anchor.setTo 0.5, 0.5
    @load.setPreloadSprite loadingBar

    @game.load.image 'background','assets/backgrounds/back.jpg', 138, 15
    @game.load.image 'canon', 'assets/sprites/cannon0001.png'
    @game.load.image 'crosshair', 'assets/sprites/crosshair.png'
    @game.load.image 'house', 'assets/sprites/house.png'
    @game.load.image 'shot', 'assets/sprites/shot.png'
    @game.load.image 'tank', 'assets/sprites/tank1.png'
    @game.load.image 'wall', 'assets/sprites/wall.png'
    @game.load.image 'cantbuild', 'assets/sprites/cantbuild.png'

    @game.load.image 'tileset', 'assets/tilemaps/tilemap.png'
    @game.load.tilemap 'map', 'assets/tilemaps/map.json', null, Phaser.Tilemap.TILED_JSON

    @game.load.audio 'sfx', ['assets/sound/drop.wav']
    @game.load.audio 'fire', ['assets/sound/cannon.wav']


  create: ->

    @game.state.start 'menu'


module.exports = Preload
