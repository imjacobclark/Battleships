import Foundation
import SpriteKit

struct BoardUI {
    func mapTileToSprite(position: Position, tile: SKShapeNode) -> SKShapeNode {
        tile.fillTexture = SKTexture(imageNamed: position.occupany.rawValue)
        
        return tile
    }
    
    func destroyedTileWithShipBlend(tile: SKShapeNode) -> SKShapeNode {
        tile.blendMode = SKBlendMode.alpha
        tile.alpha = 0.5
        tile.fillColor = .red
        
        return tile
    }
    
    func determineTileColour(position: Position, tile: SKShapeNode) -> SKShapeNode {
        var tile = tile
        
        if(position.destroyed && position.player != Player.None){
            tile = destroyedTileWithShipBlend(tile: mapTileToSprite(position: position, tile: tile))
        }else if(position.destroyed && position.player == Player.None){
            tile.fillColor = SKColor.lightGray
        }else if(position.occupany == Piece.Blank){
            tile.fillColor = SKColor.blue
        }else if(position.occupany != Piece.Blank){
            if(position.player == Player.AI){
                tile.fillColor = SKColor.blue
            }else if(position.player == Player.P1){
                tile.fillColor = SKColor.white
                tile = mapTileToSprite(position: position, tile: tile)
            }
        }
        
        return tile
    }
}
