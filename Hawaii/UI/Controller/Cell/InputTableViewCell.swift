//
//  InputTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/24/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputReasonTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
