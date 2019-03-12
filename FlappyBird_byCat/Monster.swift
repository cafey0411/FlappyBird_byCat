//
//  Monster.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/3/12.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import SpriteKit
import GameplayKit

//定义怪物
class Monster {
    
    var monster: SKSpriteNode!
    
    //出现频率
    var monsterAddFrequency : Double = 2
    
    //从右到左移动所需时间
    var monsterMoveSpeed : Double = 5
    
    //逃掉的怪物数量
    var monstersPassed : Int = 0
    
    //右侧出现的位置
    var actualFromY: CGFloat!
    
    //左侧消失的位置
    var actualToY: CGFloat!
    
    func initMonster(x: CGFloat, y: CGFloat) -> SKSpriteNode? {
        // Create sprite
        monster = SKSpriteNode(imageNamed: "monster")
        
        //右侧出现的位置
        actualFromY = random(min: monster.size.height/2, max: y - monster.size.height/2)
        
        //左侧消失的位置
        actualToY = random(min: monster.size.height/2, max: y - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: x + monster.size.width/2, y: actualFromY)
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5
    
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(monsterMoveSpeed), max: CGFloat(monsterMoveSpeed))
        
        // Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualToY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        
        //游戏结束时的动作:当怪物离开屏幕时会在场景中显示游戏结束场景
        // self前加weak,防止循环引用
        let loseAction = SKAction.run() { [weak self] in
            guard self != nil else { return }
            
            self!.addMonstersPassed()
        }
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
        return monster;
    }
    
    //获取随机位置
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        let randomA4 :CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return randomA4 * (max - min) + min
    }
    
    //怪物逃跑计数
    func addMonstersPassed() -> Int {
        monstersPassed = monstersPassed + 1
        return monstersPassed
    }
    
    //减少移动时间
    func subMonsterMoveSpeed() {
        if(monsterMoveSpeed > 0.5){
            monsterMoveSpeed -= 0.3
            print("monsterMoveSpeed: \(monsterMoveSpeed)")
        }
    }
    
    //增加出现频率
    func addMonsterFrequency() {
        if(monsterAddFrequency > 0.5){
            monsterAddFrequency -= 0.3
            monsterAddFrequency -= 0.1
            print("monsterAddFrequency: \(monsterAddFrequency)")
        }
    }
}
