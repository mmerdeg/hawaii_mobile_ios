//
//  CollapsableHeader.swift
//  Hawaii
//
//  Created by Ivan Divljak on 12/5/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

protocol ExpandProtocol: class {
    func didExpand(section: Int)
}

class CollapsableHeader: UIView {
    
    @IBOutlet weak var expandedImage: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colapseImage: UIButton!
    
    let upImage = #imageLiteral(resourceName: "upArrow").withRenderingMode(.alwaysTemplate)
    let downImage = #imageLiteral(resourceName: "downArrow").withRenderingMode(.alwaysTemplate)
    
    var section: Int?
    var tempName: String?
    var tempIsExpanded = false
    
    weak var delegate: ExpandProtocol?
    
    init(frame: CGRect, section: Int, teamName: String, isExpanded: Bool) {
        super.init(frame: frame)
        self.section = section
        tempName = teamName
        tempIsExpanded = isExpanded
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        Bundle.main.loadNibNamed(String(describing: CollapsableHeader.self), owner: self, options: nil)
        view.fixInView(self)
        let tap = UITapGestureRecognizer(target: self, action: #selector(expandAction(_:)))
        view.addGestureRecognizer(tap)
        self.titleLabel.text = tempName
        self.view.backgroundColor = UIColor.primaryColor
        expandedImage.image = tempIsExpanded ? upImage : downImage
        expandedImage.tintColor = UIColor.primaryTextColor
    }
    
    @objc func expandAction(_ sender: Any) {
        guard let section = section else {
            return
        }
        tempIsExpanded = !tempIsExpanded
        expandedImage.image = tempIsExpanded ? upImage : downImage
        delegate?.didExpand(section: section)
    }
}
