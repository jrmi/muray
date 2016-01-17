Phaser  = require 'phaser'
Map = require './classes/map'
Boot    = require './states/boot'
Preload = require './states/preload'
Menu    = require './states/menu'
Start    = require './states/start'
Main    = require './states/main'
Canon    = require './states/canon'
Fire    = require './states/fire'
Repair    = require './states/repair'


class Game extends Phaser.Game

  constructor : ->

    super 800, 600, Phaser.AUTO, 'game-content'

    @me = Map
    @state.add 'boot', Boot
    @state.add 'preload', Preload
    @state.add 'menu', Menu
    @state.add 'start', Start
    @state.add 'main', Main
    @state.add 'canon', Canon
    @state.add 'fire', Fire
    @state.add 'repair', Repair

    @state.start 'boot'


window.onload = ->

  game = new Game()
  console.log(game)