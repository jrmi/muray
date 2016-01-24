
class Main

  create : ->
    console.log('main')
    if @game.currentPlayer == 0
      @game.session.publish @game.prefix + 'turnEnded', ['main', @game.currentPlayer]
      @game.state.start 'castle', false


  onTurnEnded: (args) ->
    @game.state.start 'castle', false



module.exports = Main

