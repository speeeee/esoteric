//
//  TerseDetailViewController.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//

import UIKit

class TerseDetailViewController: UIViewController {
    
    @IBOutlet weak var tTitle: UITextField!
    @IBOutlet weak var tText: UITextView!
    @IBOutlet weak var tView: TerseView!
    var tc = TCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tTitle.text = tc.title
        tText.text = tc.text
        //tView = tc.view
        let temp = parse(tc.text)
        tView.cmds = mkCmds(temp.stk)
        /*let temp = note.text.characters.split{$0 == " "}.map(String.init)
        noteView.cmds = temp.reduce([[0.0,0.0,0.0,0.0]], combine: {(x:[[Float]],y:String) -> [[Float]] in x.last!.count%4==0 ? x + [[(y as NSString).floatValue]] : x[0..<x.count-1] + [(x.last!+[(y as NSString).floatValue])];})
        print(noteView.cmds)*/
        //noteView.setNeedsDisplay()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        tc.title = tTitle.text!
        tc.text = tText.text!
        //noteView.setNeedsDisplay()
        tc.view = tView
        tc.view.setNeedsDisplay()
        print("cmds"); print(tc.view.cmds)
        //note.date = NSDate()
    }
    
}
