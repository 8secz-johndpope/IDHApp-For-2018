//
//  ChartsOption.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/9/19.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

class ChartsOption: NSObject {
    class func standardLineOption(chartDatas:EchartsModel) -> PYOption{
        let ops = PYOption.initPYOption { (option) in
            option?.calculable = true
            //X轴
            let x = PYAxis()
            x.type = "category"
            x.data = NSMutableArray.init(array: chartDatas.xArr)
            x.axisLabel.rotate = -60
            x.axisLabel.margin = 0
            let a = PYTextStyle.init()
            a.fontSize = 8
            x.axisLabel.textStyle = a
            option?.xAxis = [x]
            //Y轴 根据结果生成一个或者多个Y轴
            var yArr:[PYAxis] = []
            var legends:[String] = []
            var seriesDataArr:[[String]] = []
            for temp in chartDatas.YaxisList{
                let y = PYAxis()
                //必须加type
                y.type = "value"
                y.name = "\(temp.name):\(temp.unit)"
                yArr.append(y)
                for item in temp.chartsDataList{
                    legends.append(item.name)
                    seriesDataArr.append(item.data)
                }
            }
            option?.yAxis = NSMutableArray.init(array: yArr)
            //legend
            option?.legend = PYLegend.initPYLegend({ (leg) in
                leg?.data = legends
            })
            //dataZoom
            option?.dataZoom = PYDataZoom.initPYDataZoom({ (zoom) in
                zoom?.show = true
                zoom?.start = 0
                zoom?.end = 100
                zoom?.showDetail = true
                zoom?.zoomLock = false
                zoom?.dataBackgroundColor = PYColor.init(hexString: "929292")
                zoom?.y = 290
//                zoom?.yAxisIndex = 10
            })
            //tooltip
            option?.tooltip = PYTooltip.initPYTooltip({ (tip) in
                tip?.trigger = PYTooltipTriggerAxis
                tip?.show = true
            })
            //series
            var sers:[PYCartesianSeries] = []
            for item in seriesDataArr.enumerated(){
                let series = PYCartesianSeries()
                series.name = legends[item.offset]
                series.data = item.element
                print(item.element)
                series.smooth = false
                series.type = PYSeriesTypeLine
                sers.append(series)
            }
            option?.series = NSMutableArray.init(array: sers)
        }
        
        return ops!
    }

}
