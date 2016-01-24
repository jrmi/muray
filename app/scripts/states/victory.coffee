
class Victory

  create : ->
    c1 = @game.countCastle(@game.currentPlayer)
    c2 = @game.countCastle(@game.otherPlayer)
    console.log(c1, c2)
    if c1 == 0 or c2 == 0

      text = @game.add.text(@game.world.centerX, @game.world.centerY - 80, '0',
      { font: "64px Arial", fill: "#ffffff", align: "center" })
      text.setText('Reload')
      text.anchor.setTo(0.5, 0.5)

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

