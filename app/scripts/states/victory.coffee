
class Victory

  create : ->
    c1 = @game.countCastle(@game.currentPlayer)
    c2 = @game.countCastle(@game.otherPlayer)

    if c1 == 0 or c2 == 0

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

