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

class Activity: UIViewController, EmpaticaDelegate, EmpaticaDeviceDelegate, ChartViewDelegate, DrawerControllerDelegate {
    
    // Mark: - Properties
    var drawer = DrawerView()
    var tabbar = AwareTabBarController()
    var step:Double = 0.0

        
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
        
        self.tabbar = tabBarController as! AwareTabBarController
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                AskConfirmation(title: "Device Found", message: "We found and connected device with id \(name).") { (connect) in self.drawer.actDissmiss()}
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
    
//    func didReceiveTag(atTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        <#code#>
//    }
//
    func didReceiveHR(_ hr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        tabbar.raw_hr.append(Double(hr))
        tabbar.hr_time.append(timestamp)
        updateHRLineChart(hrv: Double(hr))
    }

//    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        <#code#>
//    }
//
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        tabbar.raw_eda.append(gsr)
        tabbar.eda_time.append(timestamp)
        step += 0.25
        updateEDALineChart()
    }
//
//    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        <#code#>
//    }
//
//    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        <#code#>
//    }
//
//    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        <#code#>
//    }
//
    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        tabbar.batteryLevel = "\(Int(level*100))"
    }
    
    // Mark - Live Updating
    func updateEDALineChart(){
        if (step > 4) {//&& fmod(step, 1) == 0

            let start = Int(max(0, 4*step - 16))
            let end = Int(min(start+16, tabbar.raw_eda.count-1))
            let window = tabbar.raw_eda[start...end]
            let median = Double(window.sorted(by: <)[window.count / 2])

            tabbar.smooth_eda.append(median)
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
    
}


// 7.Struct for add storyboards which you want show on navigation drawer


