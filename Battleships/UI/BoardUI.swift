import Foundation
import SpriteKit

struct BoardUI {
    func determineTileColour(position: Position, tile: SKShapeNode) -> SKShapeNode {
        if(position.destroyed && position.player == Player.P1){
            tile.fillColor = SKColor.red
        }else if(position.destroyed && position.player == Player.AI){
            tile.fillColor = SKColor.red
        }else if(position.destroyed && position.player == Player.None){
            tile.fillColor = SKColor.lightGray
        }else if(position.occupany == Piece.Blank){
            tile.fillColor = SKColor.blue
        }else if(position.occupany != Piece.Blank){
            if(position.player == Player.AI){
                tile.fillColor = SKColor.blue
            }

            if(position.player == Player.P1){
                tile.fillColor = SKColor.orange
            }
        }
        
        return tile
    }
}
