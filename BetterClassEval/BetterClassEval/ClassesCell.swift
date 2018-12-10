//
//  ClassesCell.swift
//  BetterClassEval
//
//  Created by Raymond Lee on 12/7/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class ClassesCell: UITableViewCell {
    
    @IBOutlet weak var lblClassname: UILabel!
    @IBOutlet weak var lblLecturername: UILabel!
    @IBOutlet weak var lblQuarter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
