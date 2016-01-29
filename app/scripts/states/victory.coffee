
class Victory

  create : ->
    c1 = @game.countCastle(@game.currentPlayer)
    c2 = @game.countCastle(@game.otherPlayer)

    if c1 == 0 or c2 == 0
      restart = @game.add.button(@game.world.centerX, @game.world.centerY - 80, 'restart', () ->
        @game.reset()
        @game.session.publish @game.prefix + 'restart', []
        @game.state.start 'menu', true
      , this, 2, 1, 0)
      restart.anchor.setTo 0.5, 0.5

      if c1 == 0 and c2 != 0
        console.log('player 1 loose')
        @game.text.setText('You loose !')
      if c2 == 0 and c1 != 0
        console.log('player 2 loose')
        @game.text.setText('Congratulation !')
      if c1 == 0 and c2 == 0
        console.log('two players loose')
        @game.text.setText('Draw game')

    else
      @game.state.start 'canon', false



module.exports = Victory

