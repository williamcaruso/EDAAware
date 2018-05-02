//
//  Extensions.swift
//  EDA Aware
//
//  Created by William Caruso on 3/20/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
    
    struct DrawerArray {
        static let array:NSArray = ["Activity", "Journal", "Help", "Surveys", "Log Out"]
    }
    
    func AskConfirmation (title:String, message:String, completion:@escaping (_ result:Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Username"
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            
            let textField = alert.textFields![0] as UITextField
            if self.isValidUsername(username: textField.text!){
                let tabbar = self.tabBarController as! AwareTabBarController
                tabbar.username = textField.text!
                completion(true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            completion(false)
        }))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    
    func isValidUsername(username:String) -> Bool {
        return username.count > 3
    }
    
    func alertError(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        }))
        
        self.present(alert, animated: true, completion: nil)

    }

    // Mark - Drawer Navigation
    func pushTo(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showDrawer(drawer:DrawerView) -> DrawerView {
        let tabbar = self.tabBarController as! AwareTabBarController
        let drawer = DrawerView(aryControllers:DrawerArray.array, isBlurEffect:false, isHeaderInTop:true, controller:self)
        drawer.delegate = self as? DrawerControllerDelegate
        drawer.changeGradientColor(colorTop: UIColor.groupTableViewBackground, colorBottom: UIColor.white)
        drawer.changeCellTextColor(txtColor: UIColor.black)
        drawer.changeUserNameTextColor(txtColor: UIColor.black)
        drawer.changeUserName(name: tabbar.username)
        drawer.show()
        return drawer
    }
}

extension Dictionary {
    public init(keys: [Key], values: [Value]) {
        precondition(keys.count == values.count)
        
        self.init()
        
        for (index, key) in keys.enumerated() {
            self[key] = values[index]
        }
    }
}
