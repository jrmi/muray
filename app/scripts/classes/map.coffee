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


}

module.exports = Map
