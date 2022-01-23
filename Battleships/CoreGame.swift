//
//  CoreGame.swift
//  Battleships
//
//  Created by Jacob Clark on 23/01/2022.
//

import Foundation
import UIKit

let Ships: [Piece:Int] = [
    Piece.PatrolBoat: 2,
    Piece.AircraftCarrier: 5,
    Piece.Battleship: 4,
    Piece.Destroyer: 3,
    Piece.Submarine: 3
]

enum Piece {
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

struct Position {
    var x = 0
    var y = 0
    var occupany = Piece.Blank
    var destroyed = false
    var orientation = Orientation.Horizontal
}

struct Board {
    func generateBoard() -> Array<Position> {
        var positions: Array<Position> = []
        
        var row = 0
        var column = 0

        for n in 0..<101 {
            positions.append(Position(x: row, y: column))
            
            row = row + 1
            
            if(n % 10 == 0 && n != 0){
                row = 0
                column = column + 1
            }
        }
        
        return positions;
    }
    
    func placeShip(board: Array<Position>, ship: Position) -> Array<Position> {
        var board = board
        let index = 10 * ship.y + ship.x
        
        let length = Ships[ship.occupany] ?? 0
                
        if((ship.orientation == Orientation.Horizontal && ship.x + length-1 <= 9) || (ship.orientation == Orientation.Vertical && ship.y + length-1 <= 9)){
            for n in 0..<length {
                if(ship.orientation == Orientation.Horizontal) {
                    board[index + n] = Position(x: ship.x+n, y: ship.y, occupany: ship.occupany)
                }
                
                if(ship.orientation == Orientation.Vertical) {
                    board[index + (n*10)] = Position(x: ship.x, y: ship.y+n, occupany: ship.occupany)
                }
            }
        }
        
        return board
    }
    
    // Curently only placing Horizontal ships
    func placeShipRandomly(board: Array<Position>) -> Array<Position> {
        var board = board
        let avaliablePositions = board.filter { Position in
            Position.occupany == Piece.Blank
        }
        
        let position = Int.random(in: 1..<avaliablePositions.count)
//        let orientation = Int.random(in: 0...1) == 0 ? Orientation.Horizontal : Orientation.Vertical
        let orientation = Orientation.Horizontal
        
        if(orientation == Orientation.Horizontal && avaliablePositions[position+1].x == avaliablePositions[position].x+1){
            board = placeShip(board: board, ship: Position(x: avaliablePositions[position].x, y: avaliablePositions[position].y, occupany: Piece.PatrolBoat))
        }
        
        return board
    }
    
    func strike(x: Int, y: Int, board: Array<Position>) -> Array<Position> {
        var board = board
        let index = 10 * y + x
        
        if(board[index].occupany != Piece.Blank){
            board[index].destroyed = true
        }
        
        return board
    }
}
