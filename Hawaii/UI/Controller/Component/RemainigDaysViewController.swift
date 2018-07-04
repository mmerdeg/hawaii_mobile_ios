//
//  RemainigDaysViewController.swift
//  Hawaii
//
//  Created by Server on 7/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RemainigDaysViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var takenLabel: UILabel!
    
    @IBOutlet weak var pendingLabel: UILabel!
    
    @IBOutlet weak var takenDayNoLabel: UILabel!
    
    @IBOutlet weak var pendingDayNoLabel: UILabel!
    
    @IBOutlet weak var takenDaysLabel: UILabel!
    
    @IBOutlet weak var progressBar: YLProgressBar!
    
    @IBOutlet weak var remainingLabel: UILabel!
    
    @IBOutlet weak var remainingDaysLabel: UILabel!
    
    @IBOutlet weak var remainingDayNoLabel: UILabel!
    
    @IBOutlet weak var totalDayNoLabel: UILabel!
    
    var mainLabelText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.text = mainLabelText ?? ""
        mainLabel.textColor = UIColor.accentColor
        remainingLabel.textColor = UIColor.accentColor
        remainingDayNoLabel.textColor = UIColor.primaryColor
        remainingDaysLabel.textColor = UIColor.accentColor
        
        takenLabel.textColor = UIColor.accentColor
        takenDayNoLabel.textColor = UIColor.approvedColor
        takenDaysLabel.textColor = UIColor.accentColor
        pendingLabel.textColor = UIColor.accentColor
        pendingDayNoLabel.textColor = UIColor.accentColor
        totalDayNoLabel.textColor = UIColor.accentColor

        progressBar.type = .flat
        progressBar.trackTintColor = UIColor.secondaryColor
        
        progressBar.layer.borderWidth = 2
        progressBar.layer.cornerRadius = 15
        progressBar.layer.borderColor = UIColor.accentColor.cgColor
    }

}
