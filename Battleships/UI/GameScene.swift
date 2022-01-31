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
    var boardTileNodes: Array<SKShapeNode> = []
    var movableNode : SKNode?
    var movableNodeStartX: CGFloat = 0.0
    var movableNodeStartY: CGFloat = 0.0
    var shipsToBeDeployed: [String:MovablePiece] = [:]
    var shipsHaveBeenPlaced = false
    var lastRunAt: Double = 0.0
    var hasAIMoved = false
        
    func drawBoard(){
        let width = getBoxWidth()
        let view = self.view!

        let container = self.childNode(withName: "BoardContainer")
        
        var board = p1Board
        
        if(turn == Player.P1){
            board = aiBoard
        }
        
        for (_, position) in board.enumerated() {
            var x = SKShapeNode.init(rectOf: CGSize.init(width: width, height: width))
            x.name = "T" + String(position.x) + "," + String(position.y)

            x = BoardUI().determineTileColour(position: position, tile: x)
            
            let xPosition = (width * position.x) + width
            
            let yPadding = Int(view.frame.height) - (width*10)-(Int(view.safeAreaInsets.bottom))
            let yPosition = ((width * (9-position.y)) + yPadding)
            
            x.position = CGPoint(x: xPosition, y: yPosition)
            
            boardTileNodes.append(x)
            container!.addChild(x)
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
        let width = getBoxWidth()
        
        for (index, piece) in Boat().getStandardPlayableBoats().enumerated() {
            let name = piece.piece.rawValue + String(piece.number)
            addChild(Boat().generateBoat(x: width, y: Int(view.frame.height) - (width*(12+index))-(Int(view.safeAreaInsets.bottom)), piece: piece.piece, width: width, name: name))
            
            shipsToBeDeployed[name] = MovablePiece(name: name, piece: piece.piece, occupancy: Ships[piece.piece]!)
        }
        
        drawBoard()
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
                    
                    let mapToPrimitiveXPosition = (xPositionToMoveTo - width + (width/2)) / width
                                    
                    let strike = Board().strike(x: mapToPrimitiveXPosition, y: mapToPrimitiveYPosition, board: aiBoard, turn: Player.P1)
                    
                    aiBoard = strike.board
                    run(SKAction.repeat(
                            SKAction.sequence([
                                SKAction.playSoundFileNamed("missile.mp3", waitForCompletion: true),
                                SKAction.run {
                                    if((strike.hit)!.destroyed == true && (strike.hit)!.occupany != Piece.Blank){
                                        self.run(SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: true))
                                    }
                                },
                                SKAction.wait(forDuration: 1),
                                SKAction.run {
                                    self.turn = Player.AI
                                    self.redrawBoard()
                                }]),
                        count: 1))
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
            
            if let board = Board().placeShip(board: p1Board, ship: Position(x: mapToPrimitiveXPosition, y: mapToPrimitiveYPosition, occupany: shipsToBeDeployed[movableNode!.name!]!.piece, player: Player.P1)) {
                p1Board = board
                movableNode?.isHidden = true
            }
                        
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
    
    func placeAIShips() {
        Boat().getStandardPlayableBoats().forEach({ (piece: Piece, number: Int) in
            aiBoard = Board().placeShipRandomly(board: aiBoard, ship: piece)
        })
        
        shipsHaveBeenPlaced = true
        turn = Player.P1
        
        redrawBoard()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if(Board().getPlayersShips(board: p1Board, player: Player.P1).count == 19){
            if(!shipsHaveBeenPlaced){
                placeAIShips()
            }
        }
        
        if(turn == Player.AI){
            if(lastRunAt != 0 && lastRunAt + 1.0 <= currentTime){
                if(hasAIMoved == false){
                    print(difficulty)
                    let strike = Board().AITakeTurn(board: self.p1Board, level: self.difficulty)
                    p1Board = strike.board
                    
                    run(SKAction.playSoundFileNamed("missile.mp3", waitForCompletion: false))
    
                    hasAIMoved = true
                }
                
                if(lastRunAt != 0 && lastRunAt + 2.0 <= currentTime){
                    self.turn = Player.P1

                    lastRunAt = 0
                    hasAIMoved = false
                }
            }else if (lastRunAt == 0){
                lastRunAt = currentTime
            }
        }
        
        redrawBoard()
    }
}
