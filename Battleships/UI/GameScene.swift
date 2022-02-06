import SpriteKit
import GameplayKit

struct MovablePiece {
    var name: String = ""
    var piece: Piece = Piece.Blank
    var occupancy = 0
    var x = 0
    var y = 0
}

class GameScene: SKScene {
    var p1Board = Board().generateBoard()
    var aiBoard = Board().generateBoard()
    
    var difficulty = Level.Easy

    var boardTileNodes: Array<SKShapeNode> = []
    var movableNode : SKNode?
    var movableNodeStartX: CGFloat = 0.0
    var movableNodeStartY: CGFloat = 0.0
    var shipsToBeDeployed: [String:MovablePiece] = [:]
    var shipsHaveBeenPlaced = false
    
    var turnSystem = TurnSystem()
        
    func drawBoard(){
        let width = getBoxWidth()
        let view = self.view!

        let container = self.childNode(withName: "BoardContainer")
        
        var board = p1Board
        
        if(turnSystem.turn == Player.P1){
            board = aiBoard
        }
        
        for (i, position) in board.enumerated() {
            var x = SKShapeNode.init(rectOf: CGSize.init(width: width, height: width))
            x.name = "T" + String(position.x) + "," + String(position.y)
            
            let spriteIndex = BoardUI().determineSpriteIndex(currentPosition: position, board: board, i: i-1, accumulator: 0)
            x = BoardUI().determineTileColour(position: position, tile: x, spriteIndex: spriteIndex)
            
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
            
            shipsToBeDeployed[name] = MovablePiece(
                name: name,
                piece: piece.piece,
                occupancy: Ships[piece.piece]!,
                x: width,
                y: Int(view.frame.height) - (width*(12+index))-(Int(view.safeAreaInsets.bottom)))
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
            if(turnSystem.turn != Player.P1){
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
                                    self.turnSystem.turn = Player.AI
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
        if(shipsHaveBeenPlaced) {
            return
        }
        
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
            } else {
                var ship = shipsToBeDeployed[movableNode!.name!]! as MovablePiece

                movableNode?.removeFromParent()

                addChild(Boat().generateBoat(x: ship.x, y: ship.y, piece: ship.piece, width: ship.x, name: ship.name))
                
                shipsToBeDeployed[ship.name] = MovablePiece(
                    name: ship.name,
                    piece: ship.piece,
                    occupancy: ship.occupancy,
                    x: ship.x,
                    y:ship.y)
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
        turnSystem.turn = Player.P1
        
        redrawBoard()
    }
    
    func displayDestoyedPatrolBoats(){
        let nonBlankPieces = aiBoard.filter { position in
            position.occupany != Piece.Blank && position.destroyed == true
        }
        
        let patrolBoats = nonBlankPieces.filter { position in
            position.occupany == Piece.PatrolBoat
        }
        
        if(patrolBoats.count > 1 ){
            let sortedPatrolBoats = patrolBoats.sorted { a, b in
                a.x < b.x
            }
            
            if(sortedPatrolBoats[0].x+1 == sortedPatrolBoats[1].x){
                aiBoard = aiBoard.map { position in
                    var position = position
                    if(position.x == sortedPatrolBoats[0].x) {
                        position.boatTypeIsVisible = true
                    }
                    
                    if(position.x == sortedPatrolBoats[1].x) {
                        position.boatTypeIsVisible = true
                    }
                    
                    return position
                }
            }
        }
        
        if(patrolBoats.count == 4){
            let sortedPatrolBoats = patrolBoats.sorted { a, b in
                a.x < b.x
            }
            
            if(sortedPatrolBoats[2].x+1 == sortedPatrolBoats[3].x){
                aiBoard = aiBoard.map { position in
                    var position = position
                    if(position.x == sortedPatrolBoats[2].x) {
                        position.boatTypeIsVisible = true
                    }
                    
                    if(position.x == sortedPatrolBoats[3].x) {
                        position.boatTypeIsVisible = true
                    }
                    
                    return position
                }
            }
        }
    }
    
    func displayDestroyedShips(piece: Piece){
        let nonBlankPieces = aiBoard.filter { position in
            position.occupany != Piece.Blank && position.destroyed == true
        }
        
        if(nonBlankPieces.filter { position in
            position.occupany == piece
        }.count == Ships[piece]){
            aiBoard = aiBoard.enumerated().map { (index, position) -> Position in
                var position = position
                
                if(position.occupany == piece){
                    position.boatTypeIsVisible = true
                }
                
                return position
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let isGameWon = Board().isGameWon(p1Board: p1Board, aiBoard: aiBoard)
        
        if(isGameWon != Optional.none){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: EndGameViewController = storyboard.instantiateViewController(withIdentifier: "endGameView") as! EndGameViewController
            
            if let winner = isGameWon {
                vc.winner = winner == Player.P1 ? Player.P1 : Player.AI
            }
            
            vc.view.frame = (self.view?.frame)!

            vc.view.layoutIfNeeded()

            UIView.transition(with: self.view!, duration: 0, options: [], animations: {
                self.view?.window?.rootViewController = vc
            })
        }

        if(Board().getPlayersShips(board: p1Board, player: Player.P1).count == 19){
            if(!shipsHaveBeenPlaced){
                placeAIShips()
            }
        }
        
        p1Board = turnSystem.AITakeTurn(currentTime: currentTime, p1Board: p1Board, difficulty: difficulty, run: run)
        
        displayDestroyedShips(piece: Piece.Submarine)
        displayDestroyedShips(piece: Piece.Destroyer)
        displayDestroyedShips(piece: Piece.Battleship)
        displayDestroyedShips(piece: Piece.AircraftCarrier)
        displayDestoyedPatrolBoats()
        
        redrawBoard()
    }
}
