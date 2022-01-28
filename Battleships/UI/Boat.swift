import Foundation
import SpriteKit

struct Boat {
    func generateBoat(x: Int, y: Int, piece: Piece, width: Int, name: String) -> SKShapeNode {
        let sizeOfShipTilesToContain = 2
        let container = SKShapeNode.init(rectOf: CGSize.init(width: width * sizeOfShipTilesToContain, height: width))
        var xPosition = -(width/2)

        container.position = CGPoint(x: x, y:y)
        container.name = name
        container.zPosition = 90000
        
        for _ in 0..<Ships[piece]! {
            let b = SKShapeNode.init(rectOf: CGSize.init(width: width-2, height: width-2))
            b.fillColor = SKColor.green
            b.position = CGPoint(x: xPosition, y: 0)
            container.addChild(b)

            xPosition = xPosition + width
        }
                
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
