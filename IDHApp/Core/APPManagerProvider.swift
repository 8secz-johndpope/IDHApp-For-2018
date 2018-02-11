//
//  APPManagerProvider.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/3.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit

enum Versin {
    case idh, homs03, homsOther, idhWithHoms
}
enum Scene {
    case start, canshu
}

class AppProvider {
    var appVersion:Versin?
    static let instance = AppProvider()
    
    func setVersion(){
        switch currentVersion {
        case "1":
            appVersion = .idh
        case "0":
            appVersion = .homs03
        case "2":
            appVersion = .homsOther
        default:
            appVersion = .idhWithHoms
        }
    }
    
    func providerLogin() -> String {
        switch appVersion! {
        case .idh:
            return "home"
        case .idhWithHoms:
            IDH.getMapping()
            return "home"
        default:
            IDH.getTreeDataSource("topviews.xml", 1)
            return "TreeStructureViewController"
        }
    }
    func providerMonitor() -> String {
        switch appVersion! {
        case .idhWithHoms:
            return "MonitorViewController"
        default:
            return "HomsMonitorViewController"
        }
    }
    
}
