//
//  TerseView.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//

import UIKit
enum Name { case Rect; case Prn; case Line; case Pt; case RGBA; }
struct Cmd { var name : Name; var args : [Float] }

class TerseView: UIView {
    var cmds : [Cmd] = []

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
