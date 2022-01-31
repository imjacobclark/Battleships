import Foundation
import SpriteKit

struct BoardUI {
    
    func mapTileToSprite(position: Position, tile: SKShapeNode) -> SKShapeNode {
        if(position.occupany == Piece.Submarine){
            tile.fillTexture = SKTexture(imageNamed: "Submarine")
        }
        
        if(position.occupany == Piece.PatrolBoat){
            tile.fillTexture = SKTexture(imageNamed: "PatrolBoat")
        }
        
        if(position.occupany == Piece.Destroyer){
            tile.fillTexture = SKTexture(imageNamed: "Destroyer")
        }
        
        if(position.occupany == Piece.AircraftCarrier){
            tile.fillTexture = SKTexture(imageNamed: "AircraftCarrier")
        }
        
        if(position.occupany == Piece.Battleship){
            tile.fillTexture = SKTexture(imageNamed: "Battleship")
        }
        
        return tile
    }
    
    func determineTileColour(position: Position, tile: SKShapeNode) -> SKShapeNode {
        var tile = tile
        if(position.destroyed && position.player == Player.P1){
            tile.blendMode = SKBlendMode.alpha
            tile.alpha = 0.5
            tile.fillColor = .red
            tile = mapTileToSprite(position: position, tile: tile)
        }else if(position.destroyed && position.player == Player.AI){
            tile.blendMode = SKBlendMode.alpha
            tile.alpha = 0.5
            tile.fillColor = .red
            tile = mapTileToSprite(position: position, tile: tile)
        }else if(position.destroyed && position.player == Player.None){
            tile.fillColor = SKColor.lightGray
        }else if(position.occupany == Piece.Blank){
            tile.fillColor = SKColor.blue
        }else if(position.occupany != Piece.Blank){
            if(position.player == Player.AI){
                tile.fillColor = SKColor.blue
            }

            if(position.player == Player.P1){
                tile.fillColor = SKColor.white
                
                tile = mapTileToSprite(position: position, tile: tile)
            }
        }
        
        return tile
    }
}
