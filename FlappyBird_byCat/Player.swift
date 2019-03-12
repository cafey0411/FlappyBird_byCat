//
//  Player.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/3/12.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//定义主角
class Player {
    //主角定义
    var playerTextures: [SKTexture]!
    var player: SKSpriteNode!
    
    //init() {}

    func initPlayer(x: CGFloat, y: CGFloat) -> SKSpriteNode? {
        //主角为gif
        playerTextures = loadTextures(imagePath: Bundle.main.path(forResource: "player", ofType: "gif")!)
        player = SKSpriteNode(texture: playerTextures[0])
        player.position = CGPoint(x: x * 0.1, y: y * 0.5)
        
        //颜色动画
        let pulseRed = SKAction.sequence([SKAction.colorize(with: SKColor.red, colorBlendFactor: 0.5, duration: 0.2),
                                          SKAction.wait(forDuration: 0.1),
                                          SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)])
        player.run(SKAction.repeatForever(pulseRed))
        
        //增加角色的运动效果
        let flyAction = SKAction.animate(with: playerTextures, timePerFrame: 0.12)
        player.run(SKAction.repeatForever(flyAction), withKey: "fly")
        
        return player;
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
}
