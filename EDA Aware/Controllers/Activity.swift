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
import PKHUD
import AudioToolbox


class Activity: UIViewController, EmpaticaDelegate, EmpaticaDeviceDelegate, ChartViewDelegate, DrawerControllerDelegate, IAxisValueFormatter {
    
    // Mark: - Properties
    var timer = Timer()
    var time:String = ""
    
    var e4Devices:[String:E4] = [:]
    var edaDataSets:[String:LineChartDataSet] = [:]
    var edaSteps:[String:Double] = [:]
    
    // default to 5 min
    var timeFrame:Double = 300.0
    var drawer = DrawerView()
    
    
    // Mark: - Outlets
    @IBOutlet var connectionCircle: Circle!
    @IBOutlet var edaLineChartView: LineChartView!
    
    @IBOutlet var edaCurrentLabel: UILabel!
    @IBOutlet var edaHighLabel: UILabel!
    @IBOutlet var edaBaselineLabel: UILabel!
    
    @IBOutlet var timeFrameSegmentedControl: UISegmentedControl!
    
    // Mark: - Actions
    @IBAction func showSideMenu(_ sender: Any) {
        drawer = self.showDrawer(drawer: drawer)
    }
    
    @IBAction func changeTimeFrame(_ sender: Any) {
        switch timeFrameSegmentedControl.selectedSegmentIndex {
        case 0:
            timeFrame = 300.0
        case 1:
            timeFrame = 900.0
        case 2:
            timeFrame = 1800.0
        case 3:
            timeFrame = 3600.0
        default:
            timeFrame = 300.0
        }

    }
    // Mark: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        time = getTime()
    }

    // Mark: - Device Connection and Bluetooth
    func didUpdate(_ status: BLEStatus) {
        switch status {
            case kBLEStatusNotAvailable:
                print("Bluetooth low energy not available");
                PKHUD.sharedHUD.hide()
            case kBLEStatusReady:
                print("Bluetooth low energy ready");
            case kBLEStatusScanning:
                print("Bluetooth low energy scanning for devices");
                PKHUD.sharedHUD.contentView = PKHUDProgressView()
                PKHUD.sharedHUD.show()
            default:
                break
        }
    }
    
    func didDiscoverDevices(_ devices: [Any]!) {
        
        var names:[String] = []
        
        if devices.count > 0 {
            if let devices = devices as? [EmpaticaDeviceManager] {
                for device in devices {
                    print(device.name)
                    print(device.serialNumber)
                    if !device.isFaulty && device.allowed {
                        device.connect(with: self)
                        e4Devices[device.serialNumber] = E4(serialNumber: device.serialNumber)
                        edaSteps[device.serialNumber] = 0
                        names.append(device.serialNumber)
                    }
                }
            }
            
            self.setUpEDALineChart()

            let tabbar = tabBarController as! AwareTabBarController
            tabbar.deviceID = names.joined(separator: " & ")
            PKHUD.sharedHUD.contentView = PKHUDSuccessView()
            PKHUD.sharedHUD.hide()
            AskConfirmation(title: "Device Found", message: "We found and connected device with ID \(names.joined(separator: " & ")).") { (connect) in
                self.drawer.actDissmiss()
            }
        } else {
            PKHUD.sharedHUD.hide()
        }
    }

    func didUpdate(_ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        switch (status) {
            case kDeviceStatusDisconnected:
                tabbar.isConnected = false
                connectionCircle.backgroundColor = red
                AudioServicesPlaySystemSound(1521)
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
        let e4 = e4Devices[device.serialNumber]!
        e4.tagsTime.append(timestamp)
    }

    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let sn = device.serialNumber!
        let e4 = e4Devices[sn]!
        e4.rawEda.append(Double(gsr))
        e4.edaTime.append(timestamp)
        edaSteps[sn]! += 0.25
        updateEDALineChart(e4:e4)
    }

//    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        raw_acc_x.append(Double(x))
//        raw_acc_y.append(Double(y))
//        raw_acc_z.append(Double(z))
//        acc_time.append(timestamp)
//        accStep += 0.03125
//    }

    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        let tabbar = self.tabBarController as! AwareTabBarController
        tabbar.batteryLevel = "\(Int(level*100))"

    }
    
    func startSession() {
//        getPreviousEntries()
    }
    
    // Mark: - Charts
    func setUpEDALineChart() {
        
        // Initalize EDA Line Chart
        edaLineChartView.delegate = self
        edaLineChartView.chartDescription?.enabled = false
        edaLineChartView.drawGridBackgroundEnabled = false
        edaLineChartView.pinchZoomEnabled = true
        edaLineChartView.xAxis.valueFormatter = self
        
        var datasets:[LineChartDataSet] = []
        
        // Add a dataset for each device
        for (sn, e4) in e4Devices {
            var edaDataSet = LineChartDataSet(values: [], label: "EDA (\(sn))")
            edaDataSet.drawCirclesEnabled = false
            let gradientColors = [mainColor.cgColor, UIColor.clear.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [1.0, 0.2]) {
                edaDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
            }
            edaDataSet.drawFilledEnabled = true
            edaDataSet.drawValuesEnabled = false
            edaDataSet.cubicIntensity = 1
            edaDataSet.mode = .horizontalBezier
            edaDataSet.setColor(mainColor)
            
            edaDataSets[sn] = edaDataSet
            datasets.append(edaDataSet)
        }
        
        edaLineChartView.data = LineChartData(dataSets: datasets)
        edaLineChartView.rightAxis.enabled = false
        edaLineChartView.rightAxis.axisMinimum = 0
        let edaxAxis = edaLineChartView.xAxis
        edaxAxis.labelPosition = .bottom;
    }
    
    
    func updateEDALineChart(e4:E4){
        let sn = e4.serialNumber
        if (edaSteps[sn]! > 4) {
            let start = Int(max(0, 4*edaSteps[sn]! - 32))
            let end = Int(min(start+16, e4.rawEda.count-1))
            let window = e4.rawEda[start...end]
            let median = Double(window.sorted(by: <)[window.count / 2])
            
            e4.smoothEda.append(median)
            if e4.smoothEda.count > 14400 {
                self.edaDataSets[sn]?.removeFirst()
            }
            DispatchQueue.main.async(execute: {
                self.edaCurrentLabel.text = String(round(100*median)/100)
                if median > Double(self.edaHighLabel.text!)! {
                    self.edaHighLabel.text = String(round(100*median)/100)
                }
            
                let x = e4.edaTime[max(Int(4*(self.edaSteps[sn]!-2)),0)]

                let index = Array(self.edaDataSets.keys).first == sn ? 0 : 1
                print("\(sn) at index \(index)")
                self.edaLineChartView.data?.addEntry(ChartDataEntry(x: x, y: median), dataSetIndex: index)

//                let ans = self.edaDataSets[sn]?.addEntry(ChartDataEntry(x: x, y: median))
//                print("ANS \(ans)")
                self.edaLineChartView.notifyDataSetChanged()
                let minTime = e4.edaTime[max(Int(4*(self.edaSteps[sn]!-self.timeFrame)),0)]
                self.edaLineChartView.xAxis.axisMinimum = minTime
                self.edaLineChartView.moveViewToY(median, axis: .left)
                self.edaLineChartView.rightAxis.axisMinimum = 0
            })

        }
    }
    

//    @objc func baseline() {
//        let start = max(smooth_eda.count-1200, 0)
//        let b_eda = smooth_eda[start...]
//        let avg = b_eda.reduce(0, +) / Double(smooth_eda.count)
//        edaBaselineLabel.text = String(round(100*avg)/100)
//    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let dateFormatter = DateFormatter()
        let date = Date(timeIntervalSince1970: value)
        dateFormatter.dateFormat = "h:mm:ss"
        return dateFormatter.string(from: date)
    }
}
