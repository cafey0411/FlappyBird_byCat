//
//  Projectile.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/3/13.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//定义子弹
class Projectile {
    //子弹定义
    var projectile: SKSpriteNode!
    
    //子弹参数
    var projectileSize : CGFloat = 1
    var doubleShoot : Bool = false
    
    //init() {}

    func initProjectile(player: SKSpriteNode!, _ touchLocation: CGPoint) -> SKSpriteNode? {
       
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        
        //子弹大小
        projectile.xScale = projectileSize
        projectile.yScale = projectileSize
        projectile.position = player.position
        
        //物理引擎:碰撞定义
        projectile.physicsBody?.affectedByGravity = true
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        //定义了这个物体所属分类
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        //定义了哪种物体接触到该物体，该物体会收到通知（谁撞我我会收到通知）
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        //定义了哪种物体会碰撞到自己
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
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
        return projectile;
    }
    
}

