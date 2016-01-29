
class Main

  create : ->
    console.log('main')
    if @game.currentPlayer == 0
      @game.text.setText('<- You play left')
      @game.time.events.add Phaser.Timer.SECOND * 3, () ->
        @game.session.publish @game.prefix + 'turnEnded', ['main', @game.currentPlayer]
        @game.state.start 'castle', false
      , this


    else
      @game.text.setText('You play right ->')

  onTurnEnded: (args) ->
    @game.state.start 'castle', false



module.exports = Main

