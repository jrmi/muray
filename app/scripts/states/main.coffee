
class Main

  create : ->
    if @game.currentPlayer == 0
      @game.session.publish @game.prefix + 'turnEnded', ['main', @game.currentPlayer]
      @game.state.start 'canon', false


  onTurnEnded: (args) ->
    @game.state.start 'canon', false



module.exports = Main

