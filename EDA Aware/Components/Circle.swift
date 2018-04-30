//
//  Circle.swift
//  EDA Aware
//
//  Created by William Caruso on 4/29/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//


import UIKit

class Circle: UIView {
    
    override func layoutSubviews() {
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true

    }
}


