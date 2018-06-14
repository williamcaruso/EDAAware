//
//  MainTabBar.swift
//  EDA Aware
//
//  Created by William Caruso on 4/29/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class MainTabBar: UITabBar {
    
    var middleButton = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let tabItems = self.items else { return }
        tabItems[0].titlePositionAdjustment = UIOffset(horizontal: -15, vertical: 0)
        tabItems[1].titlePositionAdjustment = UIOffset(horizontal: 15, vertical: 0)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center
        
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }

    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 70, height: 70)
        middleButton.setBackgroundImage(UIImage(named: "add"), for: .normal)
        middleButton.layer.cornerRadius = 35
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 25)
        addSubview(middleButton)
    }
    
}
