Map = {

  TILES: {
    wall: 1
    walls:[1, 2]
    secured:[9, 10]
    garbage: 25
    house: 18
    tank: 17
    castle: [3, 4,11, 12]
    canon: [19, 20, 27, 28]
  }

  cantbuilds: []

  canons : []

  XYTileToWorld2: (p, map)->
    p.x = p.x * map.tileWidth + Math.round(map.tileWidth / 2)
    p.y = p.y * map.tileWidth + Math.round(map.tileHeight / 2)
    return p

  XYTileToWorld: (p, map)->
    p.x = p.x * map.tileWidth
    p.y = p.y * map.tileWidth
    return p

  XYWorldToTiledWorld: (point, layer)->
    p = new Phaser.Point()
    layer.getTileXY(point.x, point.y, p)
    @XYTileToWorld(p, layer.map)
    return  p

  addCanonTile: (x, y)->
    @map2x2.putTile(@TILES.canon, x, y)
    p = @XYTileToWorld({x:x, y:y}, @map2x2)

    canon = @map2x2.game.add.sprite p.x + Math.round(@map2x2.tileWidth / 2), p.y + Math.round(@map2x2.tileHeight / 2), 'canon'
    canon.anchor.setTo 0.5, 0.5

    @canons.push(canon)


  addCanon: (x, y)->
    p = new Phaser.Point()
    @layer1.getTileXY(x,y, p)

    @map1x1.putTile(@TILES.canon[0], p.x, p.y, 'objects')
    @map1x1.putTile(@TILES.canon[1], p.x + 1, p.y, 'objects')
    @map1x1.putTile(@TILES.canon[2], p.x, p.y + 1, 'objects')
    @map1x1.putTile(@TILES.canon[3], p.x + 1, p.y + 1, 'objects')

    p = @XYTileToWorld(p, @map1x1)

    canon = @map1x1.game.add.sprite p.x + 20, p.y + 20, 'canon'
    canon.anchor.setTo 0.5, 0.5
    @canons.push(canon)

  checkCanon: (x, y)->
    canbuild = true
    for c in @cantbuilds
      c.destroy()

    p = new Phaser.Point()
    @layer1.getTileXY(x, y, p)

    for xx in [p.x, p.x + 1]
      for yy in [p.y, p.y + 1]
        secure = @map1x1.getTile(xx, yy, 'secured')
        if @map1x1.getTile(xx, yy, 'objects') or !(secure? and secure.index == @TILES.secured[@game.currentPlayer])
          canbuild = false
          c = @map1x1.game.add.sprite  xx * 20, yy * 20, 'cantbuild'
          c.alpha = 0.5
          @cantbuilds.push(c)

    return canbuild

  addCastle: (x, y)->
    @map2x2.putTile(@TILES.castle, x, y)


}

module.exports = Map
