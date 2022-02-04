//
//  GameViewController.swift
//  Battleships
//
//  Created by Jacob Clark on 21/01/2022.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var difficulty: Level = Level.Easy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
//            if let scene = SKScene(fileNamed: "GameScene") {
//                scene.scaleMode = .aspectFill
//                view.presentScene(scene)
//            }
            
            let gc = GameScene(size: view.bounds.size)
            gc.difficulty = difficulty
            gc.scaleMode = .resizeFill
            view.presentScene(gc)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
