//
//  Journal.swift
//  EDA Aware
//
//  Created by William Caruso on 4/11/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit

class Journal: UIViewController, DrawerControllerDelegate {

    
    var drawer = DrawerView()
    
    // Mark: - Actions
    @IBAction func showSideMenu(_ sender: Any) {
        drawer = self.showDrawer(drawer: drawer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
}
