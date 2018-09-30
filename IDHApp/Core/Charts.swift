//
//  Charts.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/3/29.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import Charts


class Chart{
    
    //显示饼图
    class func setPieChart(_ pieChartView: PieChartView, dataPoints: [String], values: [Double], legendColor: [UIColor], showPie: Bool, color:UIColor = #colorLiteral(red: 0.00319302408, green: 0.6756680012, blue: 0.6819582582, alpha: 1)){
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            //\(dataPoints[i]):\(Int(values[i]))
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i] + ":\(Int(values[i]))")
            dataEntries.append(dataEntry)
        }
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.sliceSpace = 0
        pieChartDataSet.colors = legendColor
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        //设置显示百分比及百分比小数位
        let myFormatter = NumberFormatter()
        myFormatter.numberStyle = .percent
        myFormatter.multiplier = 1.0
        myFormatter.roundingIncrement = 0.01
//        myFormatter.roundingMode = .halfEven
        pieChartData.setValueFormatter(DefaultValueFormatter.init(formatter: myFormatter))
        pieChartView.data = pieChartData
        pieChartView.chartDescription?.text = ""
//        pieChartView.noDataText = "暂无数据"
        
        //隐藏饼图自带的图例
        pieChartView.legend.enabled = false
        //设置饼图显示计算后的百分比
        pieChartView.usePercentValuesEnabled = true
        //设置饼图不显示中间的空心
        pieChartView.drawHoleEnabled = false
        //设置饼图右下方的描述文字为空
        pieChartView.drawEntryLabelsEnabled = true
        
        //折线数据
//        pieChartDataSet.xValuePosition = .outsideSlice
        pieChartDataSet.yValuePosition = .outsideSlice
        
//        pieChartDataSet.valueLinePart1OffsetPercentage = 0.5
//        pieChartDataSet.valueLinePart1Length = 0.5
//        pieChartDataSet.valueLinePart2Length = 0.3
//        pieChartDataSet.valueLineWidth = 1
        pieChartDataSet.valueLineColor = UIColor.black
        pieChartDataSet.valueColors = [UIColor.black, UIColor.black]
        
        if showPie {
            pieChartView.centerText = ""
        }
        else {
            pieChartView.centerText = "暂无数据可显示！"
        }
        pieChartView.backgroundColor = color
        pieChartView.animate(xAxisDuration: 1)
    }
    
    
    class func setLineCharts(_ lineView:LineChartView, dataPoints:[String], values:[[Double]],circleRadius:CGFloat = 4, digit:Int = 2,colors:[UIColor], legend:Bool = false, legengTitle:[String] = []) {
        lineView.noDataText = "暂无数据"
        var lineChartDataSets:[LineChartDataSet] = []
        let myFormatter = NumberFormatter()
        myFormatter.numberStyle = .none
//        myFormatter.maximumIntegerDigits = digit
        
        for i in 0..<values.count {
            var dataEntries: [ChartDataEntry] = []
            for temp in 0..<dataPoints.count{
                let dataEntry = ChartDataEntry.init(x: Double(temp), y: values[i][temp])
                dataEntries.append(dataEntry)
            }
            var str = ""
            
            if legend{
                str = legengTitle[i]
            }
            let lineChartDataSet = LineChartDataSet.init(values: dataEntries, label: str)
            
            
            lineChartDataSet.highlightEnabled = false
            lineChartDataSet.circleRadius = circleRadius
            
            lineChartDataSet.setColor(colors[i])
            lineChartDataSet.valueFont = UIFont.boldSystemFont(ofSize: 9.5)
            lineChartDataSet.valueFormatter = DefaultValueFormatter.init(formatter: myFormatter)
            lineChartDataSet.valueTextColor = UIColor.black
            lineChartDataSet.lineWidth = 1.3
            lineChartDataSets.append(lineChartDataSet)
        }
        
        let chartData = LineChartData.init(dataSets: lineChartDataSets)
        
        lineView.data = chartData
//        lineView.legend.form = .line
        let l = lineView.legend
        l.form = legend ? .line : .none
        l.enabled = legend ? true : false
        l.formSize = 40
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = .white
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        
//        lineView.legend.enabled = true
//        lineView.legend.direction = .leftToRight
//        lineView.legend.formSize = 200
//        lineView.legend.formLineDashPhase = 20
//        lineView.legend.entries = [LegendEntry.init(label: "111", form: .line, formSize: 40, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor.green), LegendEntry.init(label: "222", form: .line, formSize: 40, formLineWidth: CGFloat.nan, formLineDashPhase: CGFloat.nan, formLineDashLengths: nil, formColor: UIColor.yellow)]
        
        lineView.xAxis.labelPosition = .bottom
        lineView.scaleXEnabled = true
        lineView.getAxis(.left).labelTextColor = UIColor.white
        lineView.getAxis(.left).axisMinimum = 0
//        lineView.legend.form = .none
        
        lineView.doubleTapToZoomEnabled = false
        lineView.chartDescription?.text = ""
        lineView.xAxis.drawGridLinesEnabled = false
//        lineView.xAxis.axisMaxLabels = 10
        lineView.xAxis.axisMinLabels = 1
        
        lineView.getAxis(.right).enabled = false
        lineView.noDataText = "暂无数据"
        
        lineView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
//        let fir = IndexAxisValueFormatter.init(values: dataPoints)
        
        
//        lineView.getAxis(.left).valueFormatter = DefaultValueFormatter.init(formatter: myFormatter) as! IAxisValueFormatter
        
        lineView.animate(xAxisDuration: 2.0)
        
    }

}
