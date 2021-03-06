import Foundation
import UIKit

enum Level {
    case Easy
    case Medium
    case Hard
}

let DifficultyProbabilities: [Level:Float] = [
    Level.Easy: 0.2,
    Level.Medium: 0.5,
    Level.Hard: 0.7
]

let Ships: [Piece:Int] = [
    Piece.PatrolBoat: 2,
    Piece.AircraftCarrier: 5,
    Piece.Battleship: 4,
    Piece.Destroyer: 3,
    Piece.Submarine: 3
]

enum Piece: String {
    case Blank
    case PatrolBoat
    case Battleship
    case Destroyer
    case Submarine
    case AircraftCarrier
}

enum Orientation {
    case Horizontal
    case Vertical
}

enum Player {
    case AI
    case P1
    case None
}

struct Position {
    var x = 0
    var y = 0
    var occupany = Piece.Blank
    var destroyed = false
    var orientation = Orientation.Horizontal
    var player = Player.None
    var boatTypeIsVisible = false
}

struct Board {
    func generateBoard() -> Array<Position> {
        var positions: Array<Position> = []
        
        var row = 0
        var column = 0

        for n in 1..<101 {
            positions.append(Position(x: row, y: column))
            
            row = row + 1
            
            if(n % 10 == 0 && n != 0){
                row = 0
                column = column + 1
            }
        }
        
        return positions;
    }
    
    func placeShip(board: Array<Position>, ship: Position) -> Optional<Array<Position>> {
        var board = board
        let index = 10 * ship.y + ship.x
        
        let length = Ships[ship.occupany] ?? 0

        if(!self.canShipBePlacedInLocation(board: board, ship: ship, x: index, i: 0)){
            return Optional.none
        }
                
        if((ship.orientation == Orientation.Horizontal && ship.x + length-1 <= 9) || (ship.orientation == Orientation.Vertical && ship.y + length-1 <= 9)){
            for n in 0..<length {
                if(ship.orientation == Orientation.Horizontal) {
                    if(index+n > board.count){
                        return Optional.none
                    }
                    
                    board[index + n] = Position(x: ship.x+n, y: ship.y, occupany: ship.occupany, player: ship.player)
                }
                
                if(ship.orientation == Orientation.Vertical) {
                    board[index + (n*10)] = Position(x: ship.x, y: ship.y+n, occupany: ship.occupany, player: ship.player)
                }
            }
        }
        
        return Optional.some(board)
    }
    
    func getAvaliablePositions(board: Array<Position>) -> Array<Position> {
        return board.filter { Position in
            Position.occupany == Piece.Blank
        }
    }
    
    func getOccupiedPositions(board: Array<Position>) -> Array<Position> {
        return board.filter { Position in
            Position.occupany != Piece.Blank
        }
    }
    
    func canShipBePlacedInLocation(board: Array<Position>, ship: Position, x: Int, i: Int) -> Bool {    
        if(x+i > board.count) {
            return false
        }
        
        let position = board[x+i]
        
        if(position.occupany == Piece.Blank){
            if(i == Ships[ship.occupany]! - 1){
                return true
            } else {
                return canShipBePlacedInLocation(board: board, ship: ship, x: x, i: i+1)
            }
        } else {
            return false
        }
    }
    
    // Only horizontal placement of ships is implemented presently
    func placeShipRandomly(board: Array<Position>, ship: Piece) -> Array<Position> {
        print("Placing a ", ship)
        var board = board
        let avaliablePositions = getAvaliablePositions(board: board)
        
        let position = Int.random(in: 1..<avaliablePositions.count)
        
        
        
        if(
            position+1 == avaliablePositions.count ||
            position > avaliablePositions.count ||
            avaliablePositions[position].x + Ships[ship]! > 10){
            board = placeShipRandomly(board: board, ship: ship)
        }
        
        print("Placing ", ship, avaliablePositions[position].x, avaliablePositions[position].y)
        let boardAfterShipIsPlaced = placeShip(board: board, ship: Position(x: avaliablePositions[position].x, y: avaliablePositions[position].y, occupany: ship, player: Player.AI))
        
        if let placedBoard = boardAfterShipIsPlaced {
            board = placedBoard
        } else {
            board = placeShipRandomly(board: board, ship: ship)
        }
        
        return board
    }
    
    func strike(x: Int, y: Int, board: Array<Position>, turn: Player) -> (hit: Optional<Position>, board: Array<Position>) {
        var board = board
        let index = 10 * y + x
        
        if(board[index].player == turn) {
            return (hit: Optional.none, board: board)
        }
        
        board[index].destroyed = true
        
        return (hit: Optional.some(board[index]), board: board)
    }
    
    private func getPlayersDestroyedShips(board: Array<Position>, player: Player) -> Array<Position> {
        return board.filter { position in
            position.occupany != Piece.Blank && position.player == player
        }.filter { position in
            position.destroyed == true
        }
    }
    
    func getPlayersShips(board: Array<Position>, player: Player) -> Array<Position> {
        return board.filter { position in
            position.occupany != Piece.Blank && position.player == player
        }
    }
    
    func areAllShipsDestroyedOnBoard(board: Array<Position>) -> Bool {
        return board.filter { position in
            position.occupany != Piece.Blank &&
            position.destroyed == true
        }.count == 19
    }
    
    func isGameWon(p1Board: Array<Position>, aiBoard: Array<Position>) -> Optional<Player> {
        if(areAllShipsDestroyedOnBoard(board: aiBoard)) {
            return Optional.some(Player.P1)
        }else if(areAllShipsDestroyedOnBoard(board: p1Board)) {
            return Optional.some(Player.AI)
        }
            
        return Optional.none
    }
    
    func AITakeTurn(board: Array<Position>, level: Level) -> (hit: Optional<Position>, board: Array<Position>) {
        let avaliablePositions = getAvaliablePositions(board: board).filter { Position in
            Position.destroyed == false
        }
        
        let occupiedPositions = getOccupiedPositions(board: board).filter { Position in
            Position.player != Player.AI && Position.destroyed == false
        }
                
        let randomNumberBetween0And1 = Float.random(in: 0..<1)
        var position = 0
                
        if (randomNumberBetween0And1 < DifficultyProbabilities[level]!){
            position = Int.random(in: 0..<occupiedPositions.count)
            
            if(board[position].destroyed == true) {
                return AITakeTurn(board: board, level: level)
            }
        
            return strike(x: occupiedPositions[position].x, y: occupiedPositions[position].y, board: board, turn: Player.AI)
        }else{
            if(avaliablePositions.count < 1){
                return (hit: Optional.none, board: board)
            }

            position = Int.random(in: 0..<avaliablePositions.count)

            if(board[position].destroyed == true) {
                return AITakeTurn(board: board, level: level)
            }

            return strike(x: avaliablePositions[position].x, y: avaliablePositions[position].y, board: board, turn: Player.AI)
        }
    }
}
