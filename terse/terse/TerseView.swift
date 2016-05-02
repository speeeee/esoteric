//
//  TerseView.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//

import UIKit
enum Name { case Rect; case Prn; case Line; case Pt; case RGBA; }
struct Cmd { var name : Name; var args : [CGFloat] }

class TerseView: UIView {
    var cmds : [Cmd] = []
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor(red:1.0,green:0.0,blue:0.0,alpha:1.0).CGColor)
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5)
        //cmds2.forEach{x in CGContextAddRect(context, CGRectMake(x[0],x[1],x[2],x[3]))}
        cmds2.forEach{x in switch(x.name) {
            case .Rect: CGContextAddRect(context,CGRectMake(x.args[0],x.args[1],x.args[2],x.args[3]))
            case .Line: CGContextAddLines(context,x.args,2)
            case .RGBA: CGContextSetFillColorWithColor(context,UIColor(red:x.args[0],green:x.args[1],blue:x.args[2],alpha:x.args[3]))
                CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.5)} }
        //CGContextAddRect(context, CGRectMake(10.0, 150.0, 60.0, 120.0))
        CGContextFillPath(context)
    }

}
