//
//  XMLParser.swift
//  IDHApp
//
//  Created by boolean_wang on 2018/1/9.
//  Copyright © 2018年 SR_TIMES. All rights reserved.
//

import UIKit
import KissXML

extension DDXMLElement{
    subscript(key: String) -> DDXMLElement {
        get{
            let r = self.forName(key)
            return r!
        }
    }
    
}
