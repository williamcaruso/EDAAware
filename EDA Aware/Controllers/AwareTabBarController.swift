//
//  AwareTabBarControllerViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 4/29/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class AwareTabBarController: UITabBarController {

    // Mark: - Properties
    var isConnected: Bool = Bool()
    var batteryLevel: String = ""
    var deviceID:String = "No device connected"
    var username = "Unkown User" {
        didSet {
            startSession()
        }
    }
    
    func startSession() {
        let activity = self.childViewControllers[0].childViewControllers[0] as! Activity
        activity.startSession()
    }
    
    override func viewDidLayoutSubviews() {
        let tabbar = tabBar as! MainTabBar
        tabbar.middleButton.addTarget(self, action: #selector(test), for: .touchUpInside)
    }
    
    @objc func test() {
        print("entry")
        let storyBoard = UIStoryboard(name:"Main", bundle:nil)
        let controllerName = (storyBoard.instantiateViewController(withIdentifier: "Entry"))
        controllerName.hidesBottomBarWhenPushed = true
        self.childViewControllers[selectedIndex].childViewControllers[0].pushTo(viewController: controllerName)
    }
}
