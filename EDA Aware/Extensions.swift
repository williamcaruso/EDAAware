//
//  Extensions.swift
//  EDA Aware
//
//  Created by William Caruso on 3/20/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit


extension UIViewController {
    
    struct DrawerArray {
        static let array:NSArray = ["Activity", "Journal", "Help", "Surveys", "Log Out"]
    }
    
    func AskConfirmation (title:String, message:String, completion:@escaping (_ result:Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            completion(true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completion(false)
        }))
    }
    

    // Mark - Drawer Navigation
    func pushTo(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showDrawer(drawer:DrawerView) -> DrawerView {
        let drawer = DrawerView(aryControllers:DrawerArray.array, isBlurEffect:false, isHeaderInTop:true, controller:self)
        drawer.delegate = self as? DrawerControllerDelegate
        drawer.changeGradientColor(colorTop: UIColor.groupTableViewBackground, colorBottom: UIColor.white)
        drawer.changeCellTextColor(txtColor: UIColor.black)
        drawer.changeUserNameTextColor(txtColor: UIColor.black)
        drawer.changeUserName(name: "William Caruso")
        drawer.show()
        return drawer
    }
    
}
//AskConfirmation(title: "YOUR MESSAGE TITLE", message: "YOUR MESSAGE") { (result) in
//    if result { //User has clicked on Ok
//
//    } else { //User has clicked on Cancel
//
//    }
//}
