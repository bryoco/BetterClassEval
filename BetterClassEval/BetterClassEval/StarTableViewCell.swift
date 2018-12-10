//
//  StarTableViewCell.swift
//  BetterClassEval
//
//  Created by Kyle Wistrand on 12/10/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class StarTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet var fullStars: [UIImageView]!
    @IBOutlet var halfStars: [UIImageView]!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
