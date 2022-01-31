import Foundation
import SpriteKit

struct Boat {
    func generateBoat(x: Int, y: Int, piece: Piece, width: Int, name: String) -> SKShapeNode {
        let sizeOfShipTilesToContain = Ships[piece]!
        let container = SKShapeNode.init(rectOf: CGSize.init(width: width * sizeOfShipTilesToContain, height: width))

        // Eesh, need to fix this...
        if(Ships[piece] == 2){
            container.position = CGPoint(x: x + (width/2), y:y)
            container.fillTexture = SKTexture(imageNamed: "PatrolBoat")
        }
        
        if(Ships[piece] == 3){
            container.position = CGPoint(x: x + ((width/2)*2), y:y)
            container.fillTexture = SKTexture(imageNamed: "Destroyer")
            
            if(piece == Piece.Submarine){
                container.fillTexture = SKTexture(imageNamed: "Submarine")
            }
        }
        
        if(Ships[piece] == 4){
            container.position = CGPoint(x: x + ((width/2)*3), y:y)
            container.fillTexture = SKTexture(imageNamed: "Battleship")

        }
        
        if(Ships[piece] == 5){
            container.position = CGPoint(x: x + ((width/2)*4), y:y)
            container.fillTexture = SKTexture(imageNamed: "AircraftCarrier")
        }
        
        container.name = name
        container.zPosition = 90000
        container.fillColor = .white
        container.lineWidth = 0
        return container
    }
    
    func getStandardPlayableBoats() -> Array<(piece: Piece, number: Int)>{
        return [
            (piece: Piece.PatrolBoat, number: 0),
            (piece: Piece.PatrolBoat, number: 1),
            (piece: Piece.Submarine, number: 0),
            (piece: Piece.Destroyer, number: 0),
            (piece: Piece.Battleship, number: 0),
            (piece: Piece.AircraftCarrier, number: 0)
        ]
    }
}
