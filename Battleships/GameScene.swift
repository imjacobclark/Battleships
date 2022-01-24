//
//  GameScene.swift
//  Battleships
//
//  Created by Jacob Clark on 21/01/2022.
//

import SpriteKit
import GameplayKit

var numberOfGridRows = 10

func generateBoat(x: Int, y: Int, length: Int, width: Int) -> SKShapeNode {
    let container = SKShapeNode.init(rectOf: CGSize.init(width: width*2, height: width))
    container.position = CGPoint(x: x, y:y)
    container.name = "PatrolBoat"
    container.zPosition = 90000
    var xPosition = -(width/2)
        
    for _ in 0..<length {
        let b = SKShapeNode.init(rectOf: CGSize.init(width: width-2, height: width-2))
        b.fillColor = SKColor.green
        b.strokeColor = SKColor.black
        b.position = CGPoint(x:xPosition, y:0)
        container.addChild(b)

        xPosition = xPosition + width
    }
    
    return container
}

class GameScene: SKScene {
    var board = Board().generateBoard()
    var difficulty = Level.Easy

    func setUpGame(){
        board = Board().placeShip(board: board, ship: Position(x: 0, y: 0, occupany: Piece.Destroyer, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 0, y: 4, occupany: Piece.Submarine, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 5, y: 4, occupany: Piece.AircraftCarrier, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 6, y: 8, occupany: Piece.Battleship, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 7, y: 0, occupany: Piece.PatrolBoat, player: Player.P1))
        board = Board().placeShip(board: board, ship: Position(x: 7, y: 9, occupany: Piece.PatrolBoat, player: Player.P1))

        board = Board().placeShipRandomly(board: board, ship: Piece.Destroyer)
        board = Board().placeShipRandomly(board: board, ship: Piece.Submarine)
        board = Board().placeShipRandomly(board: board, ship: Piece.AircraftCarrier)
        board = Board().placeShipRandomly(board: board, ship: Piece.Battleship)
        board = Board().placeShipRandomly(board: board, ship: Piece.PatrolBoat)
        board = Board().placeShipRandomly(board: board, ship: Piece.PatrolBoat)
    }
    
    override func sceneDidLoad() {
        let container = SKShapeNode()
        container.name = "BoardContainer"
        self.addChild(container)
    }
    
    override func didMove(to view: SKView) {
        setUpGame()
        drawBoard()
        
        let gridRowsForPadding = 1
        let width = Int(view.frame.width)/(numberOfGridRows + gridRowsForPadding)
        
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*12)-(Int(view.safeAreaInsets.bottom)), length: 2, width: width))
    }
    
    var movableNode : SKNode?
    var movableNodeStartX: CGFloat = 0.0
    var movableNodeStartY: CGFloat = 0.0
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let sprite = self.childNode(withName: "PatrolBoat")

        if let touch = touches.first {
            let location = touch.location(in: self)
            if (sprite?.contains(location))! {
                movableNode = sprite
                movableNodeStartX = (movableNode?.position.x)! - location.x
                movableNodeStartY = (movableNode?.position.y)! - location.y
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            movableNode!.position = CGPoint(x: location.x+movableNodeStartX, y: location.y+movableNodeStartY)
        }
    }
    
    
    /*
     
     It's getting late and I'm tired.. this code needs cleanin up and we need to implement snappable Y
     
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return }
        let gridRowsForPadding = 1
        
        let width = Int(view.frame.width)/(numberOfGridRows + gridRowsForPadding)
        
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            
            // Need to snap on Y
            let snappablePositionX = ((Int(location.x)+Int(movableNodeStartX))-Int(width)-(width/2)) / width

            movableNode!.position = CGPoint(x: Double((width * snappablePositionX) + width + (width/2)), y: location.y+movableNodeStartY)
        }
    }
    
    func drawBoard(){
        guard let view = self.view else { return }
        let gridRowsForPadding = 1
        
        let width = Int(view.frame.width)/(numberOfGridRows + gridRowsForPadding)
        
        let container = self.childNode(withName: "BoardContainer")

        board.forEach { position in
            let xPosition = (width * position.x) + width
            
            let yPadding = Int(view.frame.height) - (width*10)-(Int(view.safeAreaInsets.bottom))
            let yPosition = ((width * position.y) + yPadding)

            let x = SKShapeNode.init(rectOf: CGSize.init(width: width, height: width))

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

            container!.addChild(x)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
//        board = Board().AITakeTurn(board: board, level: Level.Medium).board
        
        if let BoardContainer = self.childNode(withName: "BoardContainer") {
            BoardContainer.removeAllChildren()
            drawBoard()
        }

    }
}
