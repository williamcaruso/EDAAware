//
//  ViewController.swift
//  EDA Aware
//
//  Created by William Caruso on 3/20/18.
//  Copyright © 2018 wcaruso. All rights reserved.
//

import UIKit
//import ScrollableGraphView
import Charts
import Firebase

class Activity: UIViewController, EmpaticaDelegate, EmpaticaDeviceDelegate, ChartViewDelegate, DrawerControllerDelegate {
    
    // Mark: - Properties
    var timer = Timer()
    
    var ref: DatabaseReference!
    
    var drawer = DrawerView()
    var edaStep:Double = 0.0
    var hrStep:Double = 0.0
    var accStep:Double = 0.0

    var tags: [Double] = []

    var raw_eda: [Double] = []
    var smooth_eda: [Double] = []
    var eda_time: [Double] = []
    
    var raw_hr: [Double] = []
    var hr_time: [Double] = []
    
    var raw_temp: [Double] = []
    var temp_time: [Double] = []

    var raw_bvp: [Double] = []
    var bvp_time: [Double] = []

    var raw_ibi: [Double] = []
    var ibi_time: [Double] = []

    var raw_acc_x: [Double] = []
    var raw_acc_y: [Double] = []
    var raw_acc_z: [Double] = []
    var acc_time: [Double] = []
    
    
    // Mark: - Outlets
    @IBOutlet var edaLineChartView: LineChartView!
    @IBOutlet var heartRateLineChartView: LineChartView!
    @IBOutlet var accLineChartView: LineChartView!
    @IBOutlet var connectionCircle: Circle!
    
    // Mark: - Actions
    @IBAction func showSideMenu(_ sender: Any) {
        drawer = self.showDrawer(drawer: drawer)
    }
    
    // Mark: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpEDALineChart()
        setupHRLineChart()
        setUpAccLineChart()
    }

    // Mark: - Device Connection and Bluetooth
    func didUpdate(_ status: BLEStatus) {
        switch status {
            case kBLEStatusNotAvailable:
                print("Bluetooth low energy not available");
            case kBLEStatusReady:
                print("Bluetooth low energy ready");
            case kBLEStatusScanning:
                print("Bluetooth low energy scanning for devices");
            default:
                break
        }
    }
    
    func didDiscoverDevices(_ devices: [Any]!) {
        if devices.count > 0 {
            // Connect to first available device
            let firstDevice:EmpaticaDeviceManager = devices[0] as! EmpaticaDeviceManager
            firstDevice.connect(with: self)
            if let name = firstDevice.name {
                let tabbar = tabBarController as! AwareTabBarController
                tabbar.deviceID = name
                AskConfirmation(title: "Device Found", message: "We found and connected device with ID \(name).") { (connect) in self.drawer.actDissmiss()
                }
            }
        } else {
            // error
        }
    }

    func didUpdate(_ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        switch (status) {
            case kDeviceStatusDisconnected:
                tabbar.isConnected = false
                connectionCircle.backgroundColor = red
            case kDeviceStatusConnecting:
                break
            case kDeviceStatusConnected:
                tabbar.isConnected = true
                connectionCircle.backgroundColor = green
            case kDeviceStatusDisconnecting:
                break
            default:
                break
        }
    }
    
    // Mark: - Data Inlets
    
    func didReceiveTag(atTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        tags.append(timestamp)
    }

    func didReceiveHR(_ hr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_hr.append(Double(hr))
        hr_time.append(timestamp)
    }

    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_bvp.append(Double(bvp))
        bvp_time.append(timestamp)
    }

    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_eda.append(Double(gsr))
        eda_time.append(timestamp)
        edaStep += 0.25
        updateEDALineChart()
    }

    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_ibi.append(Double(ibi))
        ibi_time.append(timestamp)
        updateHRLineChart()
    }

    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_temp.append(Double(temp))
        temp_time.append(timestamp)
    }

    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_acc_x.append(Double(x))
        raw_acc_y.append(Double(y))
        raw_acc_z.append(Double(z))
        acc_time.append(timestamp)
        accStep += 0.03125
        updateACCLineChart()
    }

    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        tabbar.batteryLevel = "\(Int(level*100))"
    }
    
    // Mark: - Firebase
    func startSession() {
        ref = Database.database().reference()
//        getPreviousE4Data()
        writeE4Data()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(writeE4Data), userInfo: nil, repeats: true)
    }
    
    func getPreviousE4Data() {
        let tabbar = tabBarController as! AwareTabBarController
        let date = getDate()
        ref.child("users/\(tabbar.username)/activity/\(date)/raw_eda").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [Double]
            self.raw_eda = value!
//            self.tags = value?["tags"] as? [Double] ?? []
//            self.raw_eda = value?["raw_eda"] as? [Double] ?? []
//            self.smooth_eda = value?["smooth_eda"] as? [Double] ?? []
//            self.eda_time = value?["eda_time"] as? [Double] ?? []
//            self.raw_hr = value?["raw_hr"] as? [Double] ?? []
//            self.raw_temp = value?["raw_temp"] as? [Double] ?? []
//            self.temp_time = value?["temp_time"] as? [Double] ?? []
//            self.raw_bvp = value?["raw_bvp"] as? [Double] ?? []
//            self.bvp_time = value?["bvp_time"] as? [Double] ?? []
//            self.raw_ibi = value?["raw_ibi"] as? [Double] ?? []
//            self.ibi_time = value?["ibi_time"] as? [Double] ?? []
//            self.raw_ibi = value?["raw_ibi"] as? [Double] ?? []
//            self.raw_acc_x = value?["raw_acc_x"] as? [Double] ?? []
//            self.raw_acc_y = value?["raw_acc_y"] as? [Double] ?? []
//            self.raw_acc_z = value?["raw_acc_z"] as? [Double] ?? []
//            self.acc_time = value?["acc_time"] as? [Double] ?? []
            print(self.raw_eda)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func writeE4Data() {
        let tabbar = tabBarController as! AwareTabBarController
        let date = getDate()

        self.ref.child("users/\(tabbar.username)/activity/\(date)").setValue([
            "tags": tags,
            "raw_eda": raw_eda,
            "smooth_eda": smooth_eda,
            "eda_time": eda_time,
            "raw_hr": raw_hr,
            "hr_time": hr_time,
            "raw_temp": raw_temp,
            "temp_time": temp_time,
            "raw_bvp": raw_bvp,
            "bvp_time": bvp_time,
            "raw_ibi": raw_ibi,
            "ibi_time": ibi_time,
            "raw_acc_x": raw_acc_x,
            "raw_acc_y": raw_acc_y,
            "raw_acc_z": raw_acc_z,
            "acc_time": acc_time
        ])
    }
    
    // Mark: - Charts
    func setUpEDALineChart() {
        
        // Initalize EDA Line Chart
        edaLineChartView.delegate = self
        edaLineChartView.chartDescription?.enabled = false
        edaLineChartView.drawGridBackgroundEnabled = false
        edaLineChartView.pinchZoomEnabled = true
        
        let initial_entry = ChartDataEntry(x: edaStep, y: 0)
        let edaDataSet: LineChartDataSet = LineChartDataSet(values: [initial_entry], label: "EDA")
        edaDataSet.drawCirclesEnabled = false
        let gradientColors = [mainColor, UIColor.clear.cgColor] as CFArray
//        let colorLocations:[CGFloat] = [1.0, 0.0]
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: nil) {
            edaDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        }
        edaDataSet.drawFilledEnabled = true // Draw the Gradient
        edaDataSet.drawValuesEnabled = false
        edaDataSet.setColor(mainColor)
        
        edaLineChartView.data = LineChartData(dataSets: [edaDataSet])
        edaLineChartView.rightAxis.enabled = false
        
        let edaxAxis = edaLineChartView.xAxis
        edaxAxis.labelPosition = .bottom;
    }
    
    func setupHRLineChart() {
        
        // Initalize Heart Rate Line Chart
        heartRateLineChartView.delegate = self
        heartRateLineChartView.chartDescription?.enabled = false
        heartRateLineChartView.drawGridBackgroundEnabled = false
        heartRateLineChartView.pinchZoomEnabled = true
        
        let initial_entry = ChartDataEntry(x: hrStep, y: 0)
        let hrDataSet: LineChartDataSet = LineChartDataSet(values: [initial_entry], label: "HR")
        hrDataSet.drawCirclesEnabled = false
        hrDataSet.drawFilledEnabled = true
        let hrGradientColors = [blue, UIColor.clear.cgColor] as CFArray
//        let hrColorLocations:[CGFloat] = [1.0, 0.0]
        if let hrGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: hrGradientColors, locations: nil) {
            hrDataSet.fill = Fill.fillWithLinearGradient(hrGradient, angle: 90.0)
            print("gradient set")
        }
        hrDataSet.drawFilledEnabled = true
        hrDataSet.drawValuesEnabled = false
        hrDataSet.setColor(blue)
        
        heartRateLineChartView.data = LineChartData(dataSets: [hrDataSet])
        heartRateLineChartView.rightAxis.enabled = false
        
        let hrxAxis = heartRateLineChartView.xAxis
        hrxAxis.labelPosition = .bottom;
    }
    
    func setUpAccLineChart() {
        
        // Initalize ACC Line Chart
        accLineChartView.delegate = self
        accLineChartView.chartDescription?.enabled = false
        accLineChartView.drawGridBackgroundEnabled = false
        accLineChartView.pinchZoomEnabled = true
        
        let initial_entry = ChartDataEntry(x: edaStep, y: 0)
        let accDataSet: LineChartDataSet = LineChartDataSet(values: [initial_entry], label: "ACC")
        accDataSet.drawCirclesEnabled = false
        let gradientColors = [lightBlue, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: nil) {
            accDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        }
        accDataSet.drawFilledEnabled = true // Draw the Gradient
        accDataSet.drawValuesEnabled = false
        accDataSet.setColor(lightBlue)
        
        accLineChartView.data = LineChartData(dataSets: [accDataSet])
        accLineChartView.rightAxis.enabled = false
        
        let xAxis = accLineChartView.xAxis
        xAxis.labelPosition = .bottom;
    }
    
    func updateEDALineChart(){
        if (edaStep > 4) {//&& fmod(step, 1) == 0
            let start = Int(max(0, 4*edaStep - 32))
            let end = Int(min(start+16, raw_eda.count-1))
            let window = raw_eda[start...end]
            let median = Double(window.sorted(by: <)[window.count / 2])
            
            smooth_eda.append(median)
            DispatchQueue.main.async {
                self.edaLineChartView.data?.addEntry(ChartDataEntry(x: self.edaStep-2, y: median), dataSetIndex: 0)
                self.edaLineChartView.setVisibleXRangeMaximum(self.edaStep-1)
                self.edaLineChartView.notifyDataSetChanged()
            }
        }
    }
    
    func updateHRLineChart() {
        print("updating hr")
        DispatchQueue.main.async {
            self.heartRateLineChartView.data?.addEntry(ChartDataEntry(x: self.ibi_time.last!, y: self.raw_ibi.last!), dataSetIndex: 0)
            self.heartRateLineChartView.setVisibleXRangeMaximum(self.hrStep+1)
            self.heartRateLineChartView.notifyDataSetChanged()
        }
    }
    
    
    func updateACCLineChart() {
        print("updating acc")
        let val = sqrt(pow(raw_acc_x.last!,2)+pow(raw_acc_y.last!,2)+pow(raw_acc_z.last!,2))
        DispatchQueue.main.async {
            self.accLineChartView.data?.addEntry(ChartDataEntry(x: self.accStep, y: val), dataSetIndex: 0)
            self.accLineChartView.setVisibleXRangeMaximum(self.acc_time.last!+1)
            self.accLineChartView.notifyDataSetChanged()
        }
    }
    
}

