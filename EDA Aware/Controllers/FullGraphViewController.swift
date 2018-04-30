////
////  FullGraphViewController.swift
////  EDA Aware
////
////  Created by William Caruso on 4/11/18.
////  Copyright © 2018 wcaruso. All rights reserved.
////
//
//import UIKit
//import ScrollableGraphView
//
//class FullGraphViewController: UIViewController, ScrollableGraphViewDataSource  {
//    
//    let numberOfItems = 50
//    //    lazy var darkLinePlotData: [Double] = self.generateRandomData(self.numberOfItems, max: 50, shouldIncludeOutliers: true)
//    //    lazy var dotPlotData: [Double] =  self.generateRandomData(self.numberOfItems, variance: 4, from: 25)
//    //
//    //
//    //    var linePlotData: [Double] {
//    //        get {
//    //            return self.generateRandomData(numberOfItems, max: 100, shouldIncludeOutliers: false)
//    //        }
//    //    }
//    //
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        let graphView = ScrollableGraphView(frame: nil, dataSource: self)
//        let linePlot = LinePlot(identifier: "line") // Identifier should be unique for each plot.
//        linePlot.lineWidth = 1
//        linePlot.lineColor = UIColor.colorFromHex("#777777")
//        linePlot.lineStyle = ScrollableGraphViewLineStyle.smooth
//        linePlot.shouldFill = true
//        linePlot.fillType = ScrollableGraphViewFillType.gradient
//        linePlot.fillGradientType = ScrollableGraphViewGradientType.linear
//        linePlot.fillGradientStartColor = UIColor.colorFromHex("#555555")
//        linePlot.fillGradientEndColor = UIColor.colorFromHex("#444444")
//
//        linePlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
//        let dotPlot = DotPlot(identifier: "darkLineDot") // Add dots as well.
//        dotPlot.dataPointSize = 2
//        dotPlot.dataPointFillColor = UIColor.white
//
//        dotPlot.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
//
//        // Setup the reference lines.
//        let referenceLines = ReferenceLines()
//        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
//        referenceLines.referenceLineColor = UIColor.white.withAlphaComponent(0.2)
//        referenceLines.referenceLineLabelColor = UIColor.white
//        referenceLines.positionType = .absolute
//        // Reference lines will be shown at these values on the y-axis.
//        referenceLines.absolutePositions = [10, 20, 25, 30]
//        referenceLines.includeMinMax = false
//        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
//
//        // Setup the graph
//        graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
//        graphView.dataPointSpacing = 80
//
//        graphView.shouldAnimateOnStartup = true
//        graphView.shouldAdaptRange = true
//        graphView.shouldRangeAlwaysStartAtZero = true
//
//        graphView.rangeMax = 50
//
//        // Add everything to the graph.
//        graphView.addReferenceLines(referenceLines: referenceLines)
//        graphView.addPlot(plot: linePlot)
//        graphView.addPlot(plot: dotPlot)
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    //    // MARK - Graphs
//        func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
//            // Return the data for each plot.
//            switch(plot.identifier) {
//            case "line":
//                return darkLinePlotData[pointIndex]
//            case "dot":
//                return dotPlotData[pointIndex]
//            default:
//                return 0
//            }
//        }
//    
//        func label(atIndex pointIndex: Int) -> String {
//            return "FEB \(pointIndex)"
//        }
//    
//        func numberOfPoints() -> Int {
//            return numberOfItems
//        }
//    
//        private func generateRandomData(_ numberOfItems: Int, max: Double, shouldIncludeOutliers: Bool = true) -> [Double] {
//            var data = [Double]()
//            for _ in 0 ..< numberOfItems {
//                var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
//    
//                if(shouldIncludeOutliers) {
//                    if(arc4random() % 100 < 10) {
//                        randomNumber *= 3
//                    }
//                }
//    
//                data.append(randomNumber)
//            }
//            return data
//        }
//    
//        private func generateRandomData(_ numberOfItems: Int, variance: Double, from: Double) -> [Double] {
//    
//            var data = [Double]()
//            for _ in 0 ..< numberOfItems {
//    
//                let randomVariance = Double(arc4random()).truncatingRemainder(dividingBy: variance)
//                var randomNumber = from
//    
//                if(arc4random() % 100 < 50) {
//                    randomNumber += randomVariance
//                }
//                else {
//                    randomNumber -= randomVariance
//                }
//    
//                data.append(randomNumber)
//            }
//            return data
//        }
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
