//
//  CoffeeTableViewCell.swift
//  CoffeeApp
//
//  Created by Kolby Sisk on 1/21/15.
//  Copyright (c) 2015 DATA, Inc. All rights reserved.
//

import UIKit

class CoffeeTableViewCell: UITableViewCell {

    @IBOutlet var brandLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
