//
//  TeamTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/19/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class TeamTableViewCell: UITableViewCell {
    
    @IBOutlet weak var teamImage: UIImageView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    
    @IBOutlet weak var teamEmailLabel: UILabel!
    
    var team: Team? {
        didSet {
            self.teamNameLabel.text = team?.name ?? ""
            self.teamEmailLabel.text = team?.emails ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.primaryColor
    }
    
}
