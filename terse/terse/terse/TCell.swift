//
//  TCell.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//

import UIKit

class TCell: NSObject, NSCoding {
    var title = ""
    var text = ""
    var view = TerseView()
    
    override init() {
        super.init()
    }
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObjectForKey("title") as! String
        self.text = aDecoder.decodeObjectForKey("text") as! String
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(text, forKey: "text")
    }
}