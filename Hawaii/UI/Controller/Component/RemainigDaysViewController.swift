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
    
    @IBOutlet weak var progressBar: UIView!
    
    @IBOutlet weak var approvedBar: UIView!
    
    @IBOutlet weak var pendingBar: UIView!
    
    @IBOutlet weak var sicknessBar: UIView!
    
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
        userUseCase?.getUser(completion: { response in
            self.user = response?.item
            guard let annual = response?.item?.allowances?.first?.annual,
                  let takenAnnual = response?.item?.allowances?.first?.takenAnnual,
                  let pendingAnnual = response?.item?.allowances?.first?.pendingAnnual,
                  let bonus = response?.item?.allowances?.first?.bonus,
                  let carriedOver = response?.item?.allowances?.first?.carriedOver,
                  let manualAdjust = response?.item?.allowances?.first?.manualAdjust,
                  let training = response?.item?.allowances?.first?.training,
                  let trainingPending = response?.item?.allowances?.first?.pendingTraining,
                  let takenTraining = response?.item?.allowances?.first?.takenTraining else {
                    self.stopActivityIndicatorSpinner()
                    return
            }
            
            let workHours = 8.0
            var total = 0.0, taken = 0.0, pending = 0.0
            
            switch self.mainLabelText {
            case "Leave":
                total = Double(annual + carriedOver + bonus + manualAdjust)
                taken = Double(takenAnnual)
                pending = Double(pendingAnnual)
            case "Training":
                total = Double(training)
                taken = Double(takenTraining)
                pending = Double(trainingPending)
            default:
                print("")
            }
            
            let totalDays = total / workHours
            self.totalDayNoLabel.text = (floor(totalDays) == totalDays ?
                String(describing: Int(totalDays)) : String(format: "%.1f", totalDays)) + " Days"
            
            let takenAnnualDays = taken / workHours
            self.takenDayNoLabel.text = floor(takenAnnualDays) == takenAnnualDays ?
                String(describing: Int(takenAnnualDays)) : String(format: "%.1f", takenAnnualDays)
            
            let remainingDays = totalDays - takenAnnualDays
            self.remainingDayNoLabel.text = floor(remainingDays) == remainingDays ?
                String(describing: Int(remainingDays)) : String(format: "%.1f", remainingDays)
            
            let pendingDays = pending / workHours
            self.pendingDayNoLabel.text = floor(pendingDays) == pendingDays ?
                String(describing: Int(pendingDays)) : String(format: "%.1f", pendingDays)
            
            let barWidth = self.progressBar.frame.width
            
            var approvedBarLen, sickBarLen, pendindgBarLen: CGFloat
            approvedBarLen = CGFloat(takenAnnualDays / totalDays) * barWidth
            pendindgBarLen = CGFloat((takenAnnualDays + pendingDays) / totalDays) * barWidth
            sickBarLen = 0
            self.approvedBar.widthAnchor.constraint(equalToConstant: approvedBarLen).isActive = true
            self.pendingBar.widthAnchor.constraint(equalToConstant: pendindgBarLen).isActive = true
            self.sicknessBar.widthAnchor.constraint(equalToConstant: sickBarLen).isActive = true
            
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
        totalDayNoLabel.textColor = UIColor.black
        totalDayNoLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        progressBar.backgroundColor = UIColor.remainingColor
        progressBar.layer.cornerRadius = 15
        
        approvedBar.backgroundColor = UIColor.approvedColor
        pendingBar.backgroundColor = UIColor.pendingColor
        sicknessBar.backgroundColor = UIColor.rejectedColor
        
    }

}
