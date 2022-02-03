import Foundation
import SpriteKit

struct BoardUI {
    func determineSpriteIndex(currentPosition: Position, board: Array<Position>, i: Int, accumulator: Int) -> Int {
        if(i > 0 && board[i].occupany == currentPosition.occupany) {
            return determineSpriteIndex(currentPosition: currentPosition, board: board, i: i - 1, accumulator: accumulator + 1)
        }
        
        return accumulator
    }
    
    func mapTileToSprite(position: Position, tile: SKShapeNode, spriteIndex: Int) -> SKShapeNode {
        tile.fillTexture = SKTexture(imageNamed: position.occupany.rawValue + String(spriteIndex))
        
        return tile
    }
    
    func destroyedTileWithShipBlend(tile: SKShapeNode) -> SKShapeNode {
        tile.blendMode = SKBlendMode.alpha
        tile.alpha = 0.5
        tile.fillColor = .red
        
        return tile
    }
    
    func determineTileColour(position: Position, tile: SKShapeNode, spriteIndex: Int) -> SKShapeNode {
        var tile = tile
        
        if(position.destroyed && position.player != Player.None){
            tile = destroyedTileWithShipBlend(tile: mapTileToSprite(position: position, tile: tile, spriteIndex: spriteIndex))
        }else if(position.destroyed && position.player == Player.None){
            tile.fillColor = SKColor.lightGray
        }else if(position.occupany == Piece.Blank){
            tile.fillColor = SKColor.blue
        }else if(position.occupany != Piece.Blank){
            if(position.player == Player.AI){
                tile.fillColor = SKColor.blue
            }else if(position.player == Player.P1){
                tile.fillColor = SKColor.white
                tile = mapTileToSprite(position: position, tile: tile, spriteIndex: spriteIndex)
            }
        }
        
        return tile
    }
}
