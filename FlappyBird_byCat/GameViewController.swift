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

fileprivate extension Selector {
    static let startBtnClick = #selector(GameViewController.startBtnEvent(sender:))
}


class GameViewController: UIViewController {

    var scene: GameScene!
    var startBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //创建游戏开始按钮
        startBtn = UIButton(type: .custom)
        startBtn.setTitle("start", for: .normal)
        startBtn.setTitleColor(.green, for: .normal)
        startBtn.titleLabel?.font = UIFont(name: "Chalkduster", size: 17)
        startBtn.frame = CGRect(x: (view.bounds.size.width - 80) * 0.5, y: 200, width: 80, height: 40)
        startBtn.layer.borderWidth = 1
        startBtn.layer.borderColor = UIColor.orange.cgColor
        startBtn.layer.cornerRadius = 2
        startBtn.layer.masksToBounds = true
        view.addSubview(startBtn)
        startBtn.addTarget(self, action: .startBtnClick, for: .touchUpInside)
        
        //增加通知器：接收通知
        NotificationCenter.default.addObserver(self, selector: #selector(notifyFunc(noti:)), name: NSNotification.Name("GameSceneNotification"), object: nil)
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
    
    //根据游戏状态来控制按钮显示
    @objc func notifyFunc(noti: Notification) {
        print("noti:\(noti)")
        if let newStatus = noti.object as? GameStatus {
            
            if newStatus == GameStatus.over {
                startBtn.isHidden = false
                //资源释放
                scene.deleteView()
            }else{
                startBtn.isHidden = true
            }
        }
    }
    
    @objc func startBtnEvent(sender: UIButton) {
        
        scene = GameScene(size: view.bounds.size)
        // Set the scene coordinates (0, 0) to the center of the screen.
        scene.anchorPoint = CGPoint(x: 0, y: 0)//往右上角方向偏移量
        //SKView：动画和渲染由SKView执行，需要在一个窗口中放置该视图，然后渲染内容。
        let skView = view as! SKView
        //指画面每秒传输帧数,Frame（画面、帧），p就是Per（每），s就是Second（秒）
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
        scene.startGame()
    }
}
