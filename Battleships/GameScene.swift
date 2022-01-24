//
//  GameScene.swift
//  Battleships
//
//  Created by Jacob Clark on 21/01/2022.
//

import SpriteKit
import GameplayKit

var gridItemHeight = 50
var gridItemWidth = 50
var gridStartX = 100
var gridStartY = 100
var gridItemPadding = 2
var numberOfGridRows = 10
var endOfGrid = gridStartY + (gridItemHeight+gridItemPadding) * numberOfGridRows

func generateBoat(x: Int, y: Int, length: Int) -> SKShapeNode {
    let container = SKShapeNode.init(rectOf: CGSize.init(width: 100, height: 50))
    container.position = CGPoint(x: x, y:y)
    var xPosition = -25
    
    for _ in 0..<length {
        let b = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
        b.fillColor = SKColor.green
        b.strokeColor = SKColor.black
        b.position = CGPoint(x:xPosition, y:0)
        container.addChild(b)
        
        xPosition = xPosition + 50
    }
    
    return container
}

class GameScene: SKScene {
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var board = Board().generateBoard()

    override func sceneDidLoad() {
        // Place user ships
        board = Board().placeShip(board: board, ship: Position(x: 0, y: 0, occupany: Piece.Destroyer, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 0, y: 4, occupany: Piece.Submarine, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 5, y: 4, occupany: Piece.AircraftCarrier, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 6, y: 8, occupany: Piece.Battleship, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 7, y: 0, occupany: Piece.PatrolBoat, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 7, y: 9, occupany: Piece.PatrolBoat, player: Player.P1))
        
        // Place AI ships
        board = Board().placeShipRandomly(board: board, ship: Piece.Destroyer)
        board = Board().placeShipRandomly(board: board, ship: Piece.Submarine)
        board = Board().placeShipRandomly(board: board, ship: Piece.AircraftCarrier)
        board = Board().placeShipRandomly(board: board, ship: Piece.Battleship)
        board = Board().placeShipRandomly(board: board, ship: Piece.PatrolBoat)
        board = Board().placeShipRandomly(board: board, ship: Piece.PatrolBoat)
                
        // User strike!
//        var strike = Board().strike(x:0, y:0, board: board, turn: Player.P1) // Shouldn't be allowed, this is a users ship!
//        board = strike.board

//        strike = Board().strike(x:5, y:0, board: board, turn: Player.P1) // Should be allowed
//        board = strike.board

    }
    
    override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        self.removeAllActions()
        self.removeAllChildren()
        
        board.forEach { position in
            let xPosition = (50 * position.x) + 100
            let yPosition = -((50 * position.y) + 100)

            let x = SKShapeNode.init(rectOf: CGSize.init(width: 50, height: 50))
            
            if(position.destroyed && position.player == Player.P1){
                x.fillColor = SKColor.red
            }else if(position.destroyed && position.player == Player.AI){
                x.fillColor = SKColor.darkGray
            }else if(position.destroyed && position.player == Player.None){
                x.fillColor = SKColor.lightGray
            }else if(position.occupany == Piece.Blank){
                x.fillColor = SKColor.blue
            }else if(position.occupany != Piece.Blank){
                if(position.player == Player.AI){
                    x.fillColor = SKColor.green
                }
                
                if(position.player == Player.P1){
                    x.fillColor = SKColor.orange
                }
            }
            x.position = CGPoint(x: xPosition, y: yPosition)
            
            self.addChild(x)
        }
        
        board = Board().AITakeTurn(board: board, level: Level.Medium).board

        self.addChild(generateBoat(x: 124, y: -endOfGrid-10, length: 2))
        self.addChild(generateBoat(x: 248, y:-endOfGrid-10, length: 2))
        self.addChild(generateBoat(x: 124, y:-endOfGrid-70, length: 3))
        self.addChild(generateBoat(x: 124, y:-endOfGrid-130, length: 3))
        self.addChild(generateBoat(x: 124, y:-endOfGrid-190, length: 4))
        self.addChild(generateBoat(x: 124, y:-endOfGrid-250, length: 5))
    }
}
