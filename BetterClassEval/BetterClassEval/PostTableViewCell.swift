//
//  PostTableViewCell.swift
//  BetterClassEval
//
//  Created by GeFrank on 12/5/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var scoreSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func slideBarChanged(_ sender: UISlider) {
        self.scoreLabel.text = "\(Int(sender.value))"
    }
}
