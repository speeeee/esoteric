//
//  TerseTableViewCell.swift
//  terse
//
//  Created by Spencer Sallay on 4/24/16.
//  Copyright © 2016 Spencer Sallay. All rights reserved.
//

import UIKit

class TerseTableViewCell: UITableViewCell {
    weak var tc : TCell!
    
    @IBOutlet weak var tTitle: UILabel!
    @IBOutlet weak var tText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupCell(tc : TCell) {
        self.tc = tc
        tTitle.text = tc.title
        tText.text = tc.text
    }
}