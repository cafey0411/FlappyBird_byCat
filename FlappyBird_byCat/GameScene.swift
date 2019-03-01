//
//  GameScene.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/2/27.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import SpriteKit
import GameplayKit
fileprivate extension Selector {
    static let startBtnClick = #selector(GameScene.startBtnEvent(sender:))
}



struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1       // 1
    static let projectile: UInt32 = 0b10      // 2
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

//Scenes：场景，游戏中的内容会被组织成场景，由SKScene对象表示。包含了精灵和其它需要渲染的内容。一个游戏，可能需要创建一个或多个SKScene类或其子类。
class GameScene: SKScene {
    // 1
    //let player = SKSpriteNode(imageNamed: "player")
    
    var monstersDestroyed = 0
    let scoreLabel = SKLabelNode(text: "SCORE:0")
    var startBtn: UIButton!
    
    var playerTextures: [SKTexture]!
    var player: SKSpriteNode!
    
    //每当场景要被呈现时，会调用该方法，并且只在第一次调用
    override func didMove(to view: SKView) {
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
    }
    
    @objc func startBtnEvent(sender: UIButton) {
        //背景颜色
        backgroundColor = SKColor(red: 80.0/255, green: 192.0/255, blue: 203.0/255, alpha: 0.3)
        
        startGame()
        startBtn.removeFromSuperview()
    }
    
     func startGame() {
        
        //增加分数label
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height - 50)
        scoreLabel.color = SKColor.red
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 18
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        //主角为gif
        playerTextures = loadTextures(imagePath: Bundle.main.path(forResource: "player", ofType: "gif")!)
        player = SKSpriteNode(texture: playerTextures[0])
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        /*
         SKPhysicsWorld，这个类基于场景，只能被修改但是不能被创建，这个类负责提供重力和检查碰撞
         设置物理世界的碰撞检测代理为场景自己，这样如果这个物理世界里面有两个可以碰撞接触的物理体碰到一起了就会通知他的代理
         */
        physicsWorld.contactDelegate = self
        
        //重复增加移动的怪物
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 2.0) //每隔2秒执行一次
                ])
        ))
        
        //增加背景音乐
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        birdStartFly()
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //创建怪物，并移动
    func addMonster() {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "monster")
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(3.0), max: CGFloat(5.0))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
    
        //游戏结束时的动作
        let loseAction = SKAction.run() { [weak self] in
            guard let `self` = self else { return }
            //场景切换动作
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    //点击画面时：创建飞镖，并发射 ：重写默认方法
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        
        //发射效果音乐
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        let touchLocation = touch.location(in: self)
    
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        //物理引擎:碰撞定义
        projectile.physicsBody?.affectedByGravity = true
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        //定义了这个物体所属分类
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        //定义了哪种物体接触到该物体，该物体会收到通知（谁撞我我会收到通知）
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        //定义了哪种物体会碰撞到自己
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions:要移动的目标坐标点
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    //击中时
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        //计数，胜利
        monstersDestroyed += 1
        scoreLabel.text = "SCORE:\(monstersDestroyed)"
        if monstersDestroyed > 5 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            view?.presentScene(gameOverScene, transition: reveal)
        }
        
        print("Hit")
        //移除击中的
        projectile.removeFromParent()
        monster.removeFromParent()
        
        //发送通知
        NotificationCenter.default.post(name: NSNotification.Name.init("GameSceneNotification"), object: monstersDestroyed)
    }
}


//添加场景代理
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
   
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
    
    //因为无法直接将gif动画在SpriteKit中播放，所以我们必须将gif中的一系列静态图片抽取出来然后形成一个动画帧
    func loadTextures(imagePath: String) -> [SKTexture]?{
        
        guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: imagePath) as CFURL, nil) else {
            return nil
        }
        
        let count = CGImageSourceGetCount(imageSource)
        var images:[CGImage] = []
        
        for i in 0..<count{
            guard let img = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {continue}
            
            images.append(img)
        }
        
        return images.map {SKTexture(cgImage:$0)}
    }
    
    //增加角色的运动效果
    func birdStartFly() {
        let flyAction = SKAction.animate(with: playerTextures, timePerFrame: 0.12)
        player.run(SKAction.repeatForever(flyAction), withKey: "fly")
    }
}
