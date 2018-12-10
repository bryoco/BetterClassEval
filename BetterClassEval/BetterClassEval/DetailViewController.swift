//
//  DetailViewController.swift
//  BetterClassEval
//
//  Created by Kyle Wistrand on 12/9/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit
import Charts

class DetailViewController: UIViewController, ChartViewDelegate, UITableViewDataSource {
    
    var currentData = EvalData.shared
    var categories = ["Instructor\'s effectiveness", "The course content", "Instructor\'s contribution", "The course as a whole"]
    var data: [ClassData] = []
    var quarterScores: [String: [String: [Double]]] = [:]
    var categoryScores: [String: [Double]] = [:]
    var quarterAvgs: [String: Double] = [:]
    var categoryAvgs: [String: Double] = [:]
    
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var starTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        detailTitle.text = currentData.professor
        scrollView.contentSize.height = 600
        starTable.dataSource = self
        starTable.rowHeight = 80
        
        QueryFirebase().query(anything: currentData.professor, completion: { results in
            //print(results)
            self.data = results
            for course in results {
                for category in self.categories {
                    let stats = course.statistics[category] as? [String]
                    
                    if stats != nil {
                        let thisScore = Double(stats![stats!.count - 1])!
                        
                        if self.quarterScores[course.quarter] == nil {
                            self.quarterScores[course.quarter] = [:]
                        }
                        
                        if self.quarterScores[course.quarter]![category] == nil {
                            self.quarterScores[course.quarter]![category] = [thisScore]
                        } else {
                            self.quarterScores[course.quarter]![category]?.append(thisScore)
                        }
                    }
                }
            }
            
            for quarter in self.quarterScores {
                var listOfScores: [Double] = []
                for category in quarter.value {
                    listOfScores.append(contentsOf: category.value)
                }
                self.quarterAvgs[quarter.key] = listOfScores.reduce(0.0, +) / Double(listOfScores.count)
            }
            
            var values: [ChartDataEntry] = []
            var avgSum: Double = 0.0
            
            for avg in self.quarterAvgs {
                values.append(ChartDataEntry(x: self.quarterStringToNumber(avg.key), y: avg.value))
                avgSum += avg.value
            }
            
            values.sort(by: { $0.x < $1.x })
            
            let set = LineChartDataSet(values: values, label: "")
            set.setColor(UIColor(red:0.29, green:0.18, blue:0.51, alpha:1.0))
            set.setCircleColor(UIColor(red:0.29, green:0.18, blue:0.51, alpha:1.0))
            
            let data = LineChartData(dataSet: set)
            
            self.chartView.xAxis.axisMinimum = values[0].x - 5
            self.chartView.xAxis.axisMaximum = values[values.count - 1].x + 5
            self.chartView.data = data
            
            let avgLine = ChartLimitLine(limit: avgSum / Double(self.quarterAvgs.count), label: "Avg")
            avgLine.lineWidth = 1
            avgLine.labelPosition = .rightTop
            avgLine.valueFont = .systemFont(ofSize: 10)
            avgLine.lineColor = UIColor(red:0.52, green:0.46, blue:0.30, alpha:1.0)
            
            let leftAxis = self.chartView.leftAxis
            leftAxis.removeAllLimitLines()
            leftAxis.addLimitLine(avgLine)
            leftAxis.granularity = 1
            leftAxis.axisMaximum = 5.5
            leftAxis.axisMinimum = 0
            leftAxis.gridColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.1)
            leftAxis.drawLimitLinesBehindDataEnabled = true
            
        })
        
        self.title = "Professor Performance"
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = true
        
        chartView.extraRightOffset = 15
        chartView.extraLeftOffset = 15
        
        chartView.xAxis.granularity = 25
        chartView.xAxis.valueFormatter = myFormatter()
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chartView.xAxis.gridColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.2)
        
        
        
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        
        chartView.animate(xAxisDuration: 0.5)
    }
    
    func quarterStringToNumber(_ qNum: String) -> Double {
        let quarterVal = qNum.prefix(2)
        let yearString = qNum.suffix(2)
        
        var quarterString : String
        
        switch quarterVal {
        case "WI":
            quarterString = "00"
        case "SP":
            quarterString = "25"
        case "SU":
            quarterString = "50"
        case "AU":
            quarterString = "75"
        default:
            quarterString = ""
        }
        
        return Double(yearString + quarterString)!
    }
    
    
    class myFormatter : IAxisValueFormatter {
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            let valString = String(Int(value))
            let yearString = valString.prefix(2)
            let quarterVal = valString.suffix(2)
            var quarterString : String
            
            switch quarterVal {
            case "00":
                quarterString = "WI"
            case "25":
                quarterString = "SP"
            case "50":
                quarterString = "SU"
            case "75":
                quarterString = "AU"
            default:
                quarterString = ""
            }
            
            return "'\(yearString) \(quarterString)"
        }
        
        
    }
    
    // Table functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "starCell", for: indexPath) as! StarTableViewCell
        
        
        
        QueryFirebase().query(anything: currentData.professor, completion: { results in
            self.data = results
            self.categoryScores = [:]
            
            if results.count > 0 {
                self.categories = []
                for statistic in results[0].statistics {
                    self.categories.append(statistic.key)
                }
                
                for course in results {
                    for category in self.categories {
                        let stats = course.statistics[category] as? [String]
                        
                        if stats != nil {
                            let thisScore = Double(stats![stats!.count - 1])!
                            
                            if self.categoryScores[category] == nil {
                                self.categoryScores[category] = [thisScore]
                            } else {
                                self.categoryScores[category]!.append(thisScore)
                            }
                        }
                    }
                }
                
                for category in self.categoryScores {
                    self.categoryAvgs[category.key] = category.value.reduce(0.0, +) / Double(category.value.count)
                }
                
                self.currentData.categories = self.categories
                
                let thisCategoryScoreDouble: Double = self.categoryAvgs[self.categories[indexPath.row]]!
                let thisCategoryScoreInt: Int = Int(self.categoryAvgs[self.categories[indexPath.row]]!)
                
                cell.categoryLabel.text = self.categories[indexPath.row]
                
                if thisCategoryScoreInt > 0 {
                    for i in stride(from: 0, to: thisCategoryScoreInt, by: 1) {
                        cell.fullStars[i].alpha = 1
                    }
                }
                
                if thisCategoryScoreDouble - Double(thisCategoryScoreInt) >= 0.5 {
                    cell.halfStars[thisCategoryScoreInt].alpha = 1
                }
            }
        })
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
