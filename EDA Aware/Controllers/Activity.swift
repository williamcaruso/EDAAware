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
    var step:Double = 0.0
    
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
    
    // Mark: - Actions
    @IBAction func showSideMenu(_ sender: Any) {
        drawer = self.showDrawer(drawer: drawer)
    }
    
    // Mark: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initalize EDA Line Chart
        edaLineChartView.delegate = self
        edaLineChartView.chartDescription?.enabled = false
        edaLineChartView.drawGridBackgroundEnabled = false
        edaLineChartView.pinchZoomEnabled = true
        
        var entry = ChartDataEntry(x: step, y: 0)
        var smooth_eda: LineChartDataSet = LineChartDataSet(values: [entry], label: "EDA")
        smooth_eda.drawCirclesEnabled = false
        smooth_eda.drawFilledEnabled = true
        smooth_eda.fillColor = .blue
        smooth_eda.drawValuesEnabled = false
        smooth_eda.cubicIntensity = 1
        smooth_eda.setColor(mainColor)
        
        edaLineChartView.data = LineChartData(dataSets: [smooth_eda])
        
        let xAxis = edaLineChartView.xAxis
        xAxis.labelPosition = .bottom;
        
        // Initalize Heart Rate Line Chart
        heartRateLineChartView.delegate = self
        heartRateLineChartView.chartDescription?.enabled = false
        heartRateLineChartView.drawGridBackgroundEnabled = false
        heartRateLineChartView.pinchZoomEnabled = true
        
        var hr_entry = ChartDataEntry(x: step, y: 0)
        var hr: LineChartDataSet = LineChartDataSet(values: [hr_entry], label: "HR")
        hr.drawCirclesEnabled = false
        hr.drawFilledEnabled = true
        hr.fillColor = .blue
        hr.drawValuesEnabled = false
        hr.cubicIntensity = 1
        hr.setColor(blue)
        
        heartRateLineChartView.data = LineChartData(dataSets: [hr])
        
        let hrxAxis = heartRateLineChartView.xAxis
        hrxAxis.labelPosition = .bottom;
        
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
                AskConfirmation(title: "Device Found", message: "We found and connected device with ID \(name).") { (connect) in self.drawer.actDissmiss()}
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
            case kDeviceStatusConnecting:
                break
            case kDeviceStatusConnected:
                tabbar.isConnected = true
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
        updateHRLineChart(hrv: Double(hr))
    }

    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_bvp.append(Double(bvp))
        bvp_time.append(timestamp)
    }

    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_eda.append(Double(gsr))
        eda_time.append(timestamp)
        step += 0.25
        updateEDALineChart()
    }

    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        raw_ibi.append(Double(ibi))
        ibi_time.append(timestamp)
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
    }

    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        tabbar.batteryLevel = "\(Int(level*100))"
    }
    
    // Mark: - Firebase
    func startSession() {
        ref = Database.database().reference()
        getPreviousE4Data()
        writeE4Data()
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(writeE4Data), userInfo: nil, repeats: true)
    }
    
    func getPreviousE4Data() {
        let tabbar = tabBarController as! AwareTabBarController
        let date = getDate()
        ref.child("users/\(tabbar.username)/activity/\(date)/raw_eda").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? [Double]
            print(value)
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
    
    // Mark: - Live Updating for Charts
    func updateEDALineChart(){
        if (step > 4) {//&& fmod(step, 1) == 0

            let start = Int(max(0, 4*step - 16))
            let end = Int(min(start+16, raw_eda.count-1))
            let window = raw_eda[start...end]
            let median = Double(window.sorted(by: <)[window.count / 2])

            smooth_eda.append(median)
            DispatchQueue.main.async {
                self.edaLineChartView.data?.addEntry(ChartDataEntry(x: self.step-2, y: median), dataSetIndex: 0)
                self.edaLineChartView.setVisibleXRangeMaximum(self.step-1)
                self.edaLineChartView.notifyDataSetChanged()
            }
        }
    }
    
    func updateHRLineChart(hrv: Double) {
        DispatchQueue.main.async {
            self.heartRateLineChartView.data?.addEntry(ChartDataEntry(x: self.step, y: hrv), dataSetIndex: 0)
            self.heartRateLineChartView.setVisibleXRangeMaximum(self.step-1)
            self.heartRateLineChartView.notifyDataSetChanged()
        }
    }
    
    // Mark: - Helper Methods
    func getDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
}

