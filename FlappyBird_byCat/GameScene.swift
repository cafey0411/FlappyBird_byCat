//
//  GameScene.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/2/27.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import SpriteKit
import GameplayKit

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
    
    //主角类
    var playerClass: Player! =  Player()
    //主角定义
    var player: SKSpriteNode!
    
    //怪物类
    var monsterClass: Monster! =  Monster()
    //怪物定义
    var monster: SKSpriteNode!
    
    //子弹类
    var projectileClass: Projectile! =  Projectile()
    
    struct WinOrLose {
        //失败条件
        static let LOSE  : Int = 3
        //胜利条件
        static let WIN   : Int = 60
    }
    
    //怪物参数u初始化
    //出现频率
    var monsterAddFrequencyTmp : Double = 2 {
        didSet {
            //
            print("restart :monsterAddFrequency:\(monsterClass.monsterAddFrequency)")
            removeAction(forKey: "addMonster")
            run(SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.run(addMonster),
                    SKAction.wait(forDuration: TimeInterval(monsterClass.monsterAddFrequency)) //每隔n秒执行一次
                    ])
            ), withKey: "addMonster")
        }
    }
    
    //击中c怪物数量
    var monstersDestroyed = 0
    //得分
    let scoreLabel = SKLabelNode(text: "SCORE:0")
    
    var gameStatus = GameStatus.idle {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name.init("GameSceneNotification"), object: gameStatus)
        }
    }
    
    //每当场景要被呈现时，会调用该方法，并且只在第一次调用
    override func didMove(to view: SKView) {
        //背景颜色
        backgroundColor = SKColor(red: 80.0/255, green: 192.0/255, blue: 203.0/255, alpha: 0.3)
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        /*
         SKPhysicsWorld，这个类基于场景，只能被修改但是不能被创建，这个类负责提供重力和检查碰撞
         设置物理世界的碰撞检测代理为场景自己，这样如果这个物理世界里面有两个可以碰撞接触的物理体碰到一起了就会通知他的代理
         */
        physicsWorld.contactDelegate = self
    }
    
     func startGame() {
        //存储数据
        let score = UserDefaults.standard.integer(forKey: "score")
        print("score:   \(score)")
        
        print("start game!")
        gameStatus = GameStatus.running
        
        //增加分数label
        scoreLabel.position = CGPoint(x: size.width * 0.5, y: size.height - 50)
        scoreLabel.color = SKColor.red
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 18
        scoreLabel.zPosition = 100
        addChild(scoreLabel)
        
        //主角为gif
        player = playerClass.initPlayer(x: size.width, y: size.height)
        addChild(player)
        
        //重复增加移动的怪物
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: TimeInterval(monsterClass.monsterAddFrequency)) //每隔n秒执行一次
                ])
        ), withKey: "addMonster")
        
        //增加背景音乐
//        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
//        backgroundMusic.autoplayLooped = true
//        addChild(backgroundMusic)
    }
    
    //创建怪物，并移动
    func addMonster() {
        // Create sprite
        monster = monsterClass.initMonster(x: size.width, y: size.height)
        // Add the monster to the scene
        addChild(monster)
    }
    
    //每一贞动画执行一次
    var sec : Int = 0 ;
    var tempNum: Int  = 0;
    override func update(_ currentTime: TimeInterval) {
        if (tempNum > 60 )
        {
            sec = sec + 1 ;
            tempNum = tempNum - 60;
            print(sec);
        }
        tempNum = tempNum + 1;
        
        if(monsterClass.monstersPassed == 1){
            projectileClass.projectileSize = 2
        }
        
        if(monsterClass.monstersPassed == 2){
            projectileClass.doubleShoot = true
        }
        
        //游戏结束
         if(monsterClass.monstersPassed >= WinOrLose.LOSE){
            gameOver()
        }
    }
    
    //点击画面时：创建飞镖，并发射 ：重写默认方法
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStatus != GameStatus.running {
            return
        }
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        
        let t_x = touch.location(in: self).x
        let t_y = touch.location(in: self).y
        let touch2: CGPoint = CGPoint(x:t_x,y:t_y)
        begianShoot(touch2)
        
        //增加双向
        if(projectileClass.doubleShoot){
            let midY : CGFloat = player.position.y
            let t_y2 : CGFloat = midY * 2 - t_y
            let touch3: CGPoint = CGPoint(x:t_x,y: t_y2)
            begianShoot(touch3)
        }
    }
    
    //发射子弹
    func begianShoot(_ touchLocation: CGPoint){
        //发射效果音乐
        //run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))

        // 3 - Determine offset of location to projectile
        let offset = touchLocation - player.position
        // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }
        
        // 2 - Set up initial location of projectile
        let projectile : SKSpriteNode! = projectileClass.initProjectile(player: player!, touchLocation)
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
    }
    
    //击中时
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        //计数，胜利
        monstersDestroyed += 1
        scoreLabel.text = "SCORE:\(monstersDestroyed)"

        //移除击中的
        projectile.removeFromParent()
        monster.removeFromParent()
        
        //游戏难度增加
        upperGameDifficulty()
        
        //游戏胜利
        gameWin()
    }
    
    //游戏难度增加
    func upperGameDifficulty(){
        //分数达到5的倍数时
        if(monstersDestroyed % 5 == 0){
            //增加出现频率 : monsterAddFrequencyTmp调用
           monsterAddFrequencyTmp = monsterClass.monsterAddFrequency
           monsterClass.addMonsterFrequency()
            
            //移动速度
           monsterClass.subMonsterMoveSpeed()
        }
    }
    
    //游戏结束
    func gameOver(){
        print("Pass")
            //场景切换动作
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.gameStatus = GameStatus.over
            //存储数据 (可存数组和字典)
            print("to save:\(self.monstersDestroyed)")
            UserDefaults.standard.set(self.monstersDestroyed, forKey: "score")
        
            let gameOverScene = GameOverScene(size: self.size, won: false, status: self.gameStatus)
            self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    //游戏胜利
    func gameWin(){
        print("Hit")
        if (monstersDestroyed >= WinOrLose.WIN){
            gameStatus = GameStatus.over
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true, status: self.gameStatus)
            view?.presentScene(gameOverScene, transition: reveal)
        }
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
    
    func deleteView() {
        self.removeAllActions()
        self.removeAllChildren()
    }
}
