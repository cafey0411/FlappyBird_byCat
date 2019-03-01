//
//  GameViewController.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/2/27.
//  Copyright © 2019 cafeyqian. All rights reserved.
//
//代码参照：https://www.raywenderlich.com/71-spritekit-tutorial-for-beginners

import UIKit
import SpriteKit
import GameplayKit



class GameViewController: UIViewController {

   
    var scene: GameScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = GameScene(size: view.bounds.size)
        // Set the scene coordinates (0, 0) to the center of the screen.
        scene.anchorPoint = CGPoint(x: 0, y: 0)
        //SKView：动画和渲染由SKView执行，需要在一个窗口中放置该视图，然后渲染内容。
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        
 

        skView.presentScene(scene)
    }


    
    override var shouldAutorotate: Bool {
        return true
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
