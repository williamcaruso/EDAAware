//
//  E4.swift
//  EDA Aware
//
//  Created by William Caruso on 6/14/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import Foundation
import UIKit

enum Wrist {
    case left
    case right
    case unknown
}

class E4: NSObject {
    
    var sessionStartTime:Double
    var serialNumber = ""
    var wrist:Wrist = .unknown
    
    var rawEda: [Double] = []
    var smoothEda: [Double] = []
    var edaTime: [Double] = []
    
    var tagsTime: [Double] = []

    init(serialNumber:String) {
        self.serialNumber = serialNumber
        self.sessionStartTime = Date().timeIntervalSince1970
    }
    
}
