//
//  UserPreviewTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class UserPreviewTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullName: UILabel!
    
    var user: User? {
        didSet {
            guard let userFullName = user?.fullName else {
                    return
            }
            profileImageView.kf.setImage(with: URL(string:
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"))
            fullName.text = userFullName
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = UIColor.darkPrimaryColor
        profileImageView.backgroundColor = UIColor.darkPrimaryColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
