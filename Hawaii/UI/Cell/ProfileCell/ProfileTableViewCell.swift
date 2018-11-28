//
//  ProfileTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 11/26/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit
import GoogleSignIn

class ProfileTableViewCell: UITableViewCell {
    
    var userDetailsUseCase: UserDetailsUseCaseProtocol?
    
    var userUseCase: UserUseCaseProtocol?
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    let genericProfileImageUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTTuYaHTYdunFCkaR7OwwMXMP_pwTxs_atlJRwBKekLVMl1iQVdag"
    
    var user: User? {
        didSet {
            self.nameLabel.text = user?.fullName
            self.emailLabel.text = user?.email
        }
    }
    
    var imageUrl: String? {
        didSet {
            profileImage.kf.setImage(with: URL(string: imageUrl ?? genericProfileImageUrl))
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.borderWidth = 1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.accentColor.cgColor
        profileImage.layer.cornerRadius = 120 / 2
        profileImage.clipsToBounds = true

    }
    
}
