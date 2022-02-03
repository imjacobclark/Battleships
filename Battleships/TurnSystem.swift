import Foundation
import SpriteKit

struct TurnSystem {
    var turn = Player.None
    var lastRunAt = 0.0
    var hasAIMoved = false
    
    mutating func AITakeTurn(currentTime: TimeInterval, p1Board: Array<Position>, difficulty: Level, run: (SKAction) -> ()) -> Array<Position> {
        var p1Board = p1Board

        if(turn == Player.AI){
            if(lastRunAt != 0 && lastRunAt + 1.0 <= currentTime){
                if(hasAIMoved == false){
                    let strike = Board().AITakeTurn(board: p1Board, level: difficulty)
                    p1Board = strike.board
                    
                    run(SKAction.playSoundFileNamed("missile.mp3", waitForCompletion: false))
    
                    hasAIMoved = true
                }
                
                if(lastRunAt != 0 && lastRunAt + 2.0 <= currentTime){
                    turn = Player.P1

                    lastRunAt = 0
                    hasAIMoved = false
                }
            }else if (lastRunAt == 0){
                print("here lra")
                lastRunAt = currentTime
            }
        }
        
        return p1Board
    }
}
