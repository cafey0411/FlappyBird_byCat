//
//  TimeTest.swift
//  FlappyBird_byCat
//
//  Created by cafeyqian on 2019/3/13.
//  Copyright © 2019 cafeyqian. All rights reserved.
//

import Foundation
import UIKit

class TimeTest : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventTimer = EventTimer()
        
        eventTimer.DispatchTimer(timeInterval: 3) { (timer) in
            print("每隔3秒执行一次！")
        }
        
        eventTimer.DispatchTimer(timeInterval: 1, repeatCount: 10) { (timer, count) in
            print("剩余执行次数 = \(count)")
        }
        
        eventTimer.DispatchAfter(after: 5) {
            print("您好")
            }
     
//        getTime { () -> () in
//            startTimer2()
//        }
    }
    /**测量一个方法的执行用时*/
    func getTime(function:()->()){
        let start=CACurrentMediaTime()
        function()
        let end=CACurrentMediaTime()
        print("方法耗时为：\(end-start)")
    }
    
 
}
