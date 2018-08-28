//
//  RemainigDaysViewController.swift
//  Hawaii
//
//  Created by Server on 7/4/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class RemainigDaysViewController: BaseViewController {

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
    
    var userUseCase: UserUseCaseProtocol?
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startActivityIndicatorSpinner()
        userUseCase?.getUser(completion: { user in
            self.user = user
            guard let annual = user?.allowances?.first?.annual,
                  let takenAnnual = user?.allowances?.first?.takenAnnual,
                  let pendingAnnual = user?.allowances?.first?.pendingAnnual,
                  let bonus = user?.allowances?.first?.bonus,
                  let carriedOver = user?.allowances?.first?.carriedOver,
                let manualAdjust = user?.allowances?.first?.manualAdjust else {
                    self.stopActivityIndicatorSpinner()
                    return
            }
            
            self.totalDayNoLabel.text = String(describing: annual + takenAnnual + pendingAnnual + carriedOver + bonus + manualAdjust)
            self.takenDayNoLabel.text = String(describing: takenAnnual)
            self.remainingDayNoLabel.text = String(describing: annual + carriedOver + bonus + manualAdjust)
            self.pendingDayNoLabel.text = String(describing: pendingAnnual)
            let total = annual + takenAnnual + pendingAnnual + carriedOver + bonus + manualAdjust
            self.progressBar.progress = CGFloat(takenAnnual / total) == 0 ? 1 : CGFloat(takenAnnual / total)
            self.stopActivityIndicatorSpinner()
        })
        
        mainLabel.text = mainLabelText ?? ""
        mainLabel.textColor = UIColor.primaryTextColor
        remainingLabel.textColor = UIColor.primaryTextColor
        remainingDayNoLabel.textColor = UIColor.primaryTextColor
        remainingDaysLabel.textColor = UIColor.primaryTextColor
        
        takenLabel.textColor = UIColor.primaryTextColor
        takenDayNoLabel.textColor = UIColor.approvedColor
        takenDaysLabel.textColor = UIColor.primaryTextColor
        pendingLabel.textColor = UIColor.primaryTextColor
        pendingDayNoLabel.textColor = UIColor.primaryTextColor
        totalDayNoLabel.textColor = UIColor.primaryTextColor

        progressBar.type = .flat
        progressBar.trackTintColor = UIColor.transparentColor
        
        progressBar.layer.borderWidth = 2
        progressBar.layer.cornerRadius = 15
        progressBar.layer.borderColor = UIColor.primaryTextColor.cgColor
    }

}
