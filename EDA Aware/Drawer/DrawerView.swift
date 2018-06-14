//
//  DrawerView.swift
//  NavigationDrawer
//
//  Created by Sowrirajan Sugumaran on 05/10/17.
//  Copyright © 2017 Sowrirajan Sugumaran. All rights reserved.
//

import UIKit

// Delegate protocolo for parsing viewcontroller to push the selected viewcontroller
protocol DrawerControllerDelegate: class {
//    func pushTo(viewController : UIViewController)
}

class DrawerView: UIView, drawerProtocolNew, UITableViewDelegate, UITableViewDataSource {
    public let screenSize = UIScreen.main.bounds
    var backgroundView = UIView()
    var drawerView = UIView()
    
    var is_connected:Bool = false {
        didSet {
            self.dissmiss()
        }
    }
    var battery_level:String = "??"
    
    var viewController = UIViewController()
    var tabbarController = AwareTabBarController()
    
    var tblVw = UITableView()
    var aryViewControllers = NSArray()
    weak var delegate:DrawerControllerDelegate?
    var currentViewController = UIViewController()
    var cellTextColor:UIColor?
    var userNameTextColor:UIColor?
    var vwForHeader = UIView()
    var vwForFooter = UIView()
    var lblunderLine = UILabel()
    var lblunderLineFooter = UILabel()
    var imgBg : UIImage?
    
    var footer_label = UILabel()
    var footer_button = UIButton()
    var battery_icon = Circle()
    var footer_battery_label = UILabel()
    var footer_icon = UIImageView()
    
    fileprivate var imgProPic = UIImageView()
    fileprivate let imgBG = UIImageView()
    fileprivate var lblUserName = UILabel()
    fileprivate var lblSubtitle = UILabel()
    fileprivate var gradientLayer: CAGradientLayer!

    convenience init(aryControllers: NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        self.init(frame: UIScreen.main.bounds)
        self.tblVw.register(UINib.init(nibName: "DrawerCell", bundle: nil), forCellReuseIdentifier: "DrawerCell")
        tblVw.isScrollEnabled = false
        
        viewController = controller
        tabbarController = controller.tabBarController as! AwareTabBarController
        is_connected = tabbarController.isConnected
        
        self.initialise(controllers: aryControllers, isBlurEffect: isBlurEffect, isHeaderInTop: isHeaderInTop, controller:controller)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // To change the profile picture of account
    func changeProfilePic(img:UIImage) {
        imgProPic.image = img
        imgBG.image = img
        imgBg = img
    }
    
    // To change the user name of account
    func changeUserName(name:String) {
        lblUserName.text = name
    }
    
    // To change the user name of account
    func changeDeviceID(name:String) {
        lblSubtitle.text = name
    }
    
    // To change battery status
    func changeBatteryLabel(name:String) {
        footer_battery_label.text = "Connected \(name)% battery"
    }
    
    // To change the background color of background view
    func changeGradientColor(colorTop:UIColor, colorBottom:UIColor) {
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // To change the tableview cell text color
    func changeCellTextColor(txtColor:UIColor) {
        self.cellTextColor = txtColor
        lblunderLine.backgroundColor = txtColor.withAlphaComponent(0.6)
        self.tblVw.reloadData()
    }
    
    // To change the user name label text color
    func changeUserNameTextColor(txtColor:UIColor) {
        lblUserName.textColor = txtColor
    }
    
    func initialise(controllers:NSArray, isBlurEffect:Bool, isHeaderInTop:Bool, controller:UIViewController) {
        currentViewController = controller
//        currentViewController.tabBarController?.tabBar.isHidden = true
        
        backgroundView.frame = frame
        drawerView.backgroundColor = UIColor.clear
        backgroundView.backgroundColor = UIColor.lightGray
        backgroundView.alpha = 0.6

        // Initialize the tap gesture to hide the drawer.
        let tap = UITapGestureRecognizer(target: self, action: #selector(DrawerView.actDissmiss))
        backgroundView.addGestureRecognizer(tap)
        addSubview(backgroundView)
        
        drawerView.frame = CGRect(x:0, y:0, width:screenSize.width/2+75, height:screenSize.height)
        drawerView.clipsToBounds = true

        // Initialize the gradient color for background view
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = drawerView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.darkGray.cgColor]

        imgBG.frame = drawerView.frame
        imgBG.image = UIImage(named: "aware")
        
        // Initialize the blur effect upon the image view for background view
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = drawerView.bounds
        imgBG.addSubview(blurView)
        
        // Check wether need the blur effect or not
        if isBlurEffect == true {
            self.drawerView.addSubview(imgBG)
        }else{
            self.drawerView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        // This is for adjusting the header frame to set header either top (isHeaderInTop:true) or bottom (isHeaderInTop:false)
        self.allocateLayout(controllers:controllers, isHeaderInTop: isHeaderInTop)
    }
    
    func allocateLayout(controllers:NSArray, isHeaderInTop:Bool) {
        
        vwForHeader = UIView(frame:CGRect(x:0, y:40, width:drawerView.frame.size.width, height:75))
        self.lblunderLine = UILabel(frame:CGRect(x:vwForHeader.frame.origin.x+10, y:vwForHeader.frame.size.height - 1 , width:vwForHeader.frame.size.width-20, height:1.0))
        tblVw.frame = CGRect(x:0, y:vwForHeader.frame.origin.y+vwForHeader.frame.size.height, width:screenSize.width/2+75, height:screenSize.height-215)

        vwForFooter = UIView(frame:CGRect(x:0, y:screenSize.height-100, width:drawerView.frame.size.width, height:screenSize.height-100))
        lblunderLineFooter.frame = CGRect(x:10, y:0, width:vwForFooter.frame.size.width-20, height:1)
    
        
        tblVw.separatorStyle = UITableViewCellSeparatorStyle.none
        aryViewControllers = controllers
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.backgroundColor = UIColor.clear   
        drawerView.addSubview(tblVw)
        tblVw.reloadData()

        lblunderLine.backgroundColor = UIColor.groupTableViewBackground
        vwForHeader.addSubview(lblunderLine)
        
        // Footer
        lblunderLineFooter.backgroundColor = UIColor.groupTableViewBackground
        vwForFooter.addSubview(lblunderLineFooter)
        
        footer_label = UILabel(frame:CGRect(x:50, y:14, width:vwForFooter.frame.size.width/2, height:25))
        footer_label.text = "E4 Sensor"
        footer_label.font = UIFont(name: "Hiragino Sans", size: 14)
        footer_label.textAlignment = .left
        vwForFooter.addSubview(footer_label)

        footer_icon = UIImageView(frame:CGRect(x:20, y:14, width:30, height:25))
        footer_icon.image = UIImage(named: "e4icon")
        footer_icon.layer.masksToBounds = true
        footer_icon.contentMode = .scaleAspectFit
        vwForFooter.addSubview(footer_icon)

        battery_icon = Circle(frame: CGRect(x: 32, y: 47, width: 11, height: 11))
        battery_icon.backgroundColor = is_connected ? green : red
        battery_icon.layer.masksToBounds = true
        vwForFooter.addSubview(battery_icon)

        footer_battery_label = UILabel(frame:CGRect(x:50, y:40, width:vwForFooter.frame.size.width, height:25))
        footer_battery_label.text = "Connected \(battery_level)% battery"
        footer_battery_label.font = UIFont(name: "Hiragino Sans", size: 11)
        footer_battery_label.textAlignment = .left
        vwForFooter.addSubview(footer_battery_label)
        
        
        if !is_connected {
            vwForFooter.frame = CGRect(x: vwForFooter.frame.minX, y: vwForFooter.frame.minY - 60, width: vwForFooter.frame.width, height: vwForFooter.frame.height + 60)
        
            footer_battery_label.text = "Not Connected"
            
            footer_button = UIButton(frame: CGRect(x: 50, y: 70, width: vwForFooter.frame.size.width/2, height: 40))
            footer_button.backgroundColor = mainColor
            footer_button.setTitle("Connect now", for: .normal)
            footer_button.titleLabel?.textColor = .white
            footer_button.titleLabel?.font = UIFont(name: "Hiragino Sans", size: 14)
            footer_button.layer.cornerRadius = 8
            footer_button.addTarget(self, action: #selector(connectNow), for: .touchUpInside)
            vwForFooter.addSubview(footer_button)
        }

        // Header
        
        lblUserName = UILabel(frame:CGRect(x:75, y:14, width:vwForHeader.frame.size.width/2+30, height:25))
        lblUserName.text = "Unknown User"
        lblUserName.font = UIFont(name: "Hiragino Sans", size: 16)
        lblUserName.textAlignment = .left
        lblUserName.textColor = UIColor.darkText
        vwForHeader.addSubview(lblUserName)
        
        lblSubtitle = UILabel(frame:CGRect(x:75, y:34, width:vwForHeader.frame.size.width/2+30, height:25))
        lblSubtitle.text = "No Device"
        lblSubtitle.font = UIFont(name: "Hiragino Sans", size: 11)
        lblSubtitle.textAlignment = .left
        lblSubtitle.textColor = UIColor.darkText
        vwForHeader.addSubview(lblSubtitle)
        
        imgProPic = UIImageView(frame:CGRect(x:10, y:lblUserName.frame.origin.y-5, width:60, height:60))
        imgProPic.image = UIImage(named: "profile")
        imgProPic.layer.cornerRadius = imgProPic.frame.size.height/2
        imgProPic.layer.masksToBounds = true
        imgProPic.contentMode = .scaleAspectFit
        vwForHeader.addSubview(imgProPic)

        drawerView.addSubview(vwForHeader)
        drawerView.addSubview(vwForFooter)
        addSubview(drawerView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryViewControllers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerCell") as! DrawerCell
        cell.backgroundColor = UIColor.clear
        cell.lblController?.text = aryViewControllers[indexPath.row] as? String
        cell.lblController.textColor = self.cellTextColor ?? UIColor.white

        if let id = viewController.restorationIdentifier {
            if id == aryViewControllers[indexPath.row] as? String {
                cell.lblController.textColor = UIColor(red: 1, green: 0.541, blue: 0.467, alpha: 1.00)
            }
        }
    
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        actDissmiss()
        let selected = aryViewControllers[indexPath.row] as! String
        switch selected {
        case "Activity":
            tabbarController.selectedIndex = 0
        case "Journal":
            tabbarController.selectedIndex = 1
        default:
            let storyBoard = UIStoryboard(name:"Main", bundle:nil)
            let controllerName = (storyBoard.instantiateViewController(withIdentifier: selected))
            controllerName.hidesBottomBarWhenPushed = true
            viewController.pushTo(viewController: controllerName)
        }
    }

    // To dissmiss the current view controller tab bar along with navigation drawer
    @objc func actDissmiss() {
        currentViewController.tabBarController?.tabBar.isHidden = false
        self.dissmiss()
    }
    
    // Action for logout to quit the application.
    @objc func actLogOut() {
        exit(0)
    }
    
    @objc func connectNow() {
        let activity = tabbarController.childViewControllers[0].childViewControllers[0]
        EmpaticaAPI.discoverDevices(with: activity as! EmpaticaDelegate)
    }
}
