import SpriteKit
import GameplayKit

struct MovablePiece {
    var name: String = ""
    var piece: Piece = Piece.Blank
    var occupancy = 0
}

class GameScene: SKScene {
    var p1Board = Board().generateBoard()
    var aiBoard = Board().generateBoard()
    var difficulty = Level.Easy
    var turn = Player.None
    var txt = SKLabelNode(text: "Hello World")
    var boardTileNodes: Array<SKShapeNode> = []
    var movableNode : SKNode?
    var movableNodeStartX: CGFloat = 0.0
    var movableNodeStartY: CGFloat = 0.0
    var shipsToBeDeployed: [String:MovablePiece] = [:]
    var shipsHaveBeenPlaced = false
    var lastRunAt: Double = 0.0
    var hasAIMoved = false

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
        
        shipsToBeDeployed[name] = MovablePiece(name: name, piece: piece, occupancy: Ships[piece]!)
        
        return container
    }
    
    func drawBoard(){
        let width = getBoxWidth()
        let view = self.view!

        let container = self.childNode(withName: "BoardContainer")
        
        var board = p1Board
        
        if(turn == Player.P1){
            board = aiBoard
        }
        
        for (index, position) in board.enumerated() {
            let x = SKShapeNode.init(rectOf: CGSize.init(width: width, height: width))
            x.name = "T" + String(position.x) + "," + String(position.y)

            if(position.destroyed && position.player == Player.P1){
                x.fillColor = SKColor.red
            }else if(position.destroyed && position.player == Player.AI){
                x.fillColor = SKColor.red
            }else if(position.destroyed && position.player == Player.None){
                x.fillColor = SKColor.lightGray
            }else if(position.occupany == Piece.Blank){
                x.fillColor = SKColor.blue
            }else if(position.occupany != Piece.Blank){
                if(position.player == Player.AI){
                    x.fillColor = SKColor.blue
                }

                if(position.player == Player.P1){
                    x.fillColor = SKColor.orange
                }
            }
            
            let xPosition = (width * position.x) + width
            
            let yPadding = Int(view.frame.height) - (width*10)-(Int(view.safeAreaInsets.bottom))
            let yPosition = ((width * (9-position.y)) + yPadding)
            
            x.position = CGPoint(x: xPosition, y: yPosition)
            
            boardTileNodes.append(x)
        }
        
        boardTileNodes.forEach { node in
            container!.addChild(node)
        }
    }
    
    override func sceneDidLoad() {
        let container = SKShapeNode()
        container.name = "BoardContainer"
        self.addChild(container)
    }
    
    func getBoxWidth() -> Int {
        let gridRowsForPadding = 1
        let numberOfGridRows = 10
        
        let view = self.view!
        
        return Int(view.frame.width)/(numberOfGridRows + gridRowsForPadding)
    }
    
    override func didMove(to view: SKView) {
        drawBoard()
        
        let width = getBoxWidth()
        
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*12)-(Int(view.safeAreaInsets.bottom)), piece: Piece.PatrolBoat, width: width, name: "PatrolBoat01"))
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*13)-(Int(view.safeAreaInsets.bottom)), piece: Piece.PatrolBoat, width: width, name: "PatrolBoat02"))
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*14)-(Int(view.safeAreaInsets.bottom)), piece: Piece.Submarine, width: width, name: "Submarine"))
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*15)-(Int(view.safeAreaInsets.bottom)), piece: Piece.Destroyer, width: width, name: "Destroyer"))
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*16)-(Int(view.safeAreaInsets.bottom)), piece: Piece.Battleship, width: width, name: "Battleship"))
        addChild(generateBoat(x: width + 15, y: Int(view.frame.height) - (width*17)-(Int(view.safeAreaInsets.bottom)), piece: Piece.AircraftCarrier, width: width, name: "Carrier"))
        
        redrawBoard()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let width = getBoxWidth()
        let view = self.view!
        
        shipsToBeDeployed.forEach { name in
            let sprite = self.childNode(withName: name.key)
            
            if let touch = touches.first {
                let location = touch.location(in: self)
                if (sprite?.contains(location))! {
                    movableNode = sprite
                    movableNodeStartX = (movableNode?.position.x)! - location.x
                    movableNodeStartY = (movableNode?.position.y)! - location.y
                }
            }
        }
        
        boardTileNodes.forEach { sprite in
            if(turn != Player.P1){
                return
            }
            
            if let touch = touches.first {
                let location = touch.location(in: self)
                if (sprite.contains(location)) {
                    let xPositionToMoveTo = Int(location.x)
                    let yPositionToMoveTo = Int(location.y)
                    
                    let yPadding = Int(view.frame.height) - (width*10)-(Int(view.safeAreaInsets.bottom))
                    let mapToPrimitiveYPosition = abs((yPadding + ((((Int(yPositionToMoveTo) / width) - yPadding) - width)) + 16))
                    
                    let mapToPrimitiveXPosition = (xPositionToMoveTo - width) / width
                                        
                    aiBoard = Board().strike(x: mapToPrimitiveXPosition, y: mapToPrimitiveYPosition, board: aiBoard, turn: Player.P1).board

                    run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run {
                        self.turn = Player.AI
                        self.txt.text = "Computers move"
                        self.redrawBoard()
                    }]), count: 1))

                }
            }
        }
        
        redrawBoard()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            movableNode!.position = CGPoint(x: location.x+movableNodeStartX, y: location.y+movableNodeStartY)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let width = getBoxWidth()
        let view = self.view!
        
        if let touch = touches.first, movableNode != nil {
            let location = touch.location(in: self)
            
            let yPositionToMoveTo = Double(Int(location.y) + Int(movableNodeStartY))
            let yPadding = Int(view.frame.height) - (width*10)-(Int(view.safeAreaInsets.bottom))
            let mapToPrimitiveYPosition = abs((yPadding + ((((Int(yPositionToMoveTo) / width) - yPadding) - width)) + 16))
            
            let xPositionToMoveTo = Int(location.x) + Int(movableNodeStartX)
            let mapToPrimitiveXPosition = (xPositionToMoveTo - width - (width / 2) ) / width
            
            p1Board = Board().placeShip(board: p1Board, ship: Position(x: mapToPrimitiveXPosition, y: mapToPrimitiveYPosition, occupany: shipsToBeDeployed[movableNode!.name!]!.piece, player: Player.P1))
                        
            movableNode?.isHidden = true
        }
        
        movableNode = nil
        redrawBoard()
    }
    
    func redrawBoard() {
        if let BoardContainer = self.childNode(withName: "BoardContainer") {
            BoardContainer.removeAllChildren()
            boardTileNodes = []
            drawBoard()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if(Board().getPlayersShips(board: p1Board, player: Player.P1).count == 19){
            if(!shipsHaveBeenPlaced){
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.Destroyer)
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.Submarine)
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.AircraftCarrier)
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.Battleship)
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.PatrolBoat)
                aiBoard = Board().placeShipRandomly(board: aiBoard, ship: Piece.PatrolBoat)
                shipsHaveBeenPlaced = true
                
                txt.position = CGPoint(x: getBoxWidth() + 45, y: Int(view!.frame.height) - (getBoxWidth()*12)-(Int(view!.safeAreaInsets.bottom)))
                txt.text = "Your move"
                turn = Player.P1
                addChild(txt)
                
                redrawBoard()
            }
        }
        
        if(turn == Player.AI){
            if(lastRunAt != 0 && lastRunAt + 1.0 <= currentTime){
                if(hasAIMoved == false){
                    self.p1Board = Board().AITakeTurn(board: self.p1Board, level: self.difficulty).board
                    hasAIMoved = true
                    redrawBoard()
                }
                
                if(lastRunAt != 0 && lastRunAt + 2.0 <= currentTime){
                    self.turn = Player.P1

                    self.txt.text = "Your move"
                    lastRunAt = 0
                    hasAIMoved = false
                    redrawBoard()
                }
            }else if (lastRunAt == 0){
                lastRunAt = currentTime
            }
        } else {
            redrawBoard()
        }
    }
}
