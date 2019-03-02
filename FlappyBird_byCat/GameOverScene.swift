//
//  GameOverScene.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/2/28.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import SpriteKit

enum GameStatus {
    case idle
    case running
    case over
}

class GameOverScene: SKScene {
    init(size: CGSize, won:Bool, status:GameStatus) {
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        
        // 2
        let message = won ? "You Won!" : "You Lose :["
        
        // 3
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        //发送通知
        NotificationCenter.default.post(name: NSNotification.Name.init("GameSceneNotification"), object: status)
        
        // 4
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() { [weak self] in
                // 5
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
              
            }
            ]))
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
