//
//  LoadMoreTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var loadMore: UILabel!
    @IBOutlet weak var loadingMore: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // loadMore.text = LocalizedKeys.General.loadMore.localized()
        loadMore.textColor = UIColor.primaryColor
      //  loadingMore.text = LocalizedKeys.General.loadingMore.localized()
        loadingMore.textColor = UIColor.primaryColor
        activityIndicator.color = UIColor.primaryColor
        loadingMore.isHidden = true
    }
    
}
