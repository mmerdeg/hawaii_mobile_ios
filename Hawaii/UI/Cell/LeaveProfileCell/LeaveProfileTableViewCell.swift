//
//  LeaveProfileTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LeaveProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leaveProfileImage: UIImageView!
    
    @IBOutlet weak var leaveProfileNameLabel: UILabel!
    
    @IBOutlet weak var leaveProfileCommentLabel: UILabel!
    
    var leaveProfile: LeaveProfile? {
        didSet {
            self.leaveProfileNameLabel.text = leaveProfile?.name ?? ""
            self.leaveProfileCommentLabel.text = leaveProfile?.comment ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor
    }
    
}
