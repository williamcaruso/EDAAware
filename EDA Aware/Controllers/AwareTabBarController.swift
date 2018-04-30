//
//  AwareTabBarControllerViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 4/29/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class AwareTabBarController: UITabBarController {

    var isConnected: Bool = Bool()
    var batteryLevel: String = ""
    
    var raw_eda: [Float] = []
    var smooth_eda: [Double] = []
    var eda_time: [Double] = []
    
    var raw_hr: [Double] = []
    var hr_time: [Double] = []
    
    var raw_acc_x: [Double] = []
    var raw_acc_y: [Double] = []
    var raw_acc_z: [Double] = []
    var acc_time: [Double] = []
}
