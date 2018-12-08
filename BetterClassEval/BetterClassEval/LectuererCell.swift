//
//  LectuererCell.swift
//  BetterClassEval
//
//  Created by Raymond Lee on 12/5/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class LectuererCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDept: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
