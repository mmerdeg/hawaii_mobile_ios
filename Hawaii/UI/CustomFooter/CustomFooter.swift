//
//  CustomFooter.swift
//  Hawaii
//
//  Created by Ivan Divljak on 12/3/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class CustomFooter: UIView {
    
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
    
    @IBOutlet weak var pendingDaysLabel: UILabel!
    
    @IBOutlet weak var remainingDayNoLabel: UILabel!
    
    @IBOutlet weak var totalDayNoLabel: UILabel!
    
    @IBOutlet weak var approvedBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var pendingBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sicknessBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var mainLabelTraining: UILabel!
    
    @IBOutlet weak var takenLabelTraining: UILabel!
    
    @IBOutlet weak var pendingLabelTraining: UILabel!
    
    @IBOutlet weak var takenDayNoLabelTraining: UILabel!
    
    @IBOutlet weak var pendingDayNoLabelTraining: UILabel!
    
    @IBOutlet weak var takenDaysLabelTraining: UILabel!
    
    @IBOutlet weak var progressBarTraining: UIView!
    
    @IBOutlet weak var approvedBarTraining: UIView!
    
    @IBOutlet weak var pendingBarTraining: UIView!
    
    @IBOutlet weak var sicknessBarTraining: UIView!
    
    @IBOutlet weak var remainingLabelTraining: UILabel!
    
    @IBOutlet weak var remainingDaysLabelTraining: UILabel!
    
    @IBOutlet weak var remainingDayNoLabelTraining: UILabel!
    
    @IBOutlet weak var totalDayNoLabelTraining: UILabel!
    
    @IBOutlet weak var approvedBarWidthTraining: NSLayoutConstraint!
    
    @IBOutlet weak var pendingBarWidthTraining: NSLayoutConstraint!
    
    @IBOutlet weak var sicknessBarWidthTraining: NSLayoutConstraint!
    
    var view: UIView!
    var user: User? {
        didSet {
            guard let annual = self.user?.allowances?.first?.annual,
                let takenAnnual = self.user?.allowances?.first?.takenAnnual,
                let pendingAnnual = self.user?.allowances?.first?.pendingAnnual,
                let bonus = self.user?.allowances?.first?.bonus,
                let carriedOver = self.user?.allowances?.first?.carriedOver,
                let manualAdjust = self.user?.allowances?.first?.manualAdjust,
                let training = self.user?.allowances?.first?.training,
                let trainingPending = self.user?.allowances?.first?.pendingTraining,
                let takenTraining = self.user?.allowances?.first?.takenTraining else {
                    return
            }
            var total = 0.0, taken = 0.0, pending = 0.0, totalTrain = 0.0, takenTrain = 0.0, pendingTrain = 0.0
            
            total = Double(annual + carriedOver + bonus + manualAdjust)
            taken = Double(takenAnnual)
            pending = Double(pendingAnnual)
            totalTrain = Double(training)
            takenTrain = Double(takenTraining)
            pendingTrain = Double(trainingPending)
            
            let trainingData = TrainingData(trainingTotal: totalTrain, trainingPending: pendingTrain, trainingTaken: takenTrain)
            let leaveData = LeaveData(leaveTotal: total, leavePending: pending, leaveTaken: taken)
            self.populateViewData(trainingData: trainingData, leaveData: leaveData)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.primaryColor
        mainLabel.text = LocalizedKeys.RemainingDays.leave.localized()
        mainLabel.textColor = UIColor.primaryTextColor
        remainingLabel.textColor = UIColor.primaryTextColor
        remainingDayNoLabel.textColor = UIColor.primaryTextColor
        remainingDaysLabel.textColor = UIColor.primaryTextColor
        
        takenLabel.textColor = UIColor.primaryTextColor
        takenDayNoLabel.textColor = UIColor.approvedColor
        takenDaysLabel.textColor = UIColor.primaryTextColor
        pendingLabel.textColor = UIColor.primaryTextColor
        pendingDayNoLabel.textColor = UIColor.pendingColor
        totalDayNoLabel.textColor = UIColor.black
        totalDayNoLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        progressBar.backgroundColor = UIColor.remainingColor
        progressBar.layer.cornerRadius = 15
        
        approvedBar.backgroundColor = UIColor.approvedColor
        pendingBar.backgroundColor = UIColor.pendingColor
        sicknessBar.backgroundColor = UIColor.rejectedColor
        
        takenLabel.text = LocalizedKeys.RemainingDays.taken.localized()
        pendingLabel.text = LocalizedKeys.RemainingDays.pending.localized()
        remainingLabel.text = LocalizedKeys.RemainingDays.remaining.localized()
        takenDaysLabel.text = LocalizedKeys.RemainingDays.days.localized()
        remainingDaysLabel.text = LocalizedKeys.RemainingDays.days.localized()
        
        mainLabelTraining.text = LocalizedKeys.RemainingDays.training.localized()
        mainLabelTraining.textColor = UIColor.primaryTextColor
        remainingLabelTraining.textColor = UIColor.primaryTextColor
        remainingDayNoLabelTraining.textColor = UIColor.primaryTextColor
        remainingDaysLabelTraining.textColor = UIColor.primaryTextColor
        
        takenLabelTraining.textColor = UIColor.primaryTextColor
        takenDayNoLabelTraining.textColor = UIColor.approvedColor
        takenDaysLabelTraining.textColor = UIColor.primaryTextColor
        pendingLabelTraining.textColor = UIColor.primaryTextColor
        pendingDayNoLabelTraining.textColor = UIColor.pendingColor
        totalDayNoLabelTraining.textColor = UIColor.black
        totalDayNoLabelTraining.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        progressBarTraining.backgroundColor = UIColor.remainingColor
        progressBarTraining.layer.cornerRadius = 15
        
        approvedBarTraining.backgroundColor = UIColor.approvedColor
        pendingBarTraining.backgroundColor = UIColor.pendingColor
        sicknessBarTraining.backgroundColor = UIColor.rejectedColor
        
        takenLabelTraining.text = LocalizedKeys.RemainingDays.taken.localized()
        pendingLabelTraining.text = LocalizedKeys.RemainingDays.pending.localized()
        remainingLabelTraining.text = LocalizedKeys.RemainingDays.remaining.localized()
        takenDaysLabelTraining.text = LocalizedKeys.RemainingDays.days.localized()
        remainingDaysLabelTraining.text = LocalizedKeys.RemainingDays.days.localized()
    }
    
    func populateViewData(trainingData: TrainingData, leaveData: LeaveData) {
        
        let workHours = 8.0
        
        let totalDaysLabelExtension = " " + LocalizedKeys.RemainingDays.days.localized().capitalized
        
        var totalDays = (leaveData.leaveTotal ?? 0.0) / workHours
        self.totalDayNoLabel.text = (floor(totalDays) == totalDays ?
            String(describing: Int(totalDays)) : String(format: ViewConstants.halfDayFormat, totalDays)) + totalDaysLabelExtension
        
        var takenAnnualDays = (leaveData.leaveTaken ?? 0.0) / workHours
        self.takenDayNoLabel.text = floor(takenAnnualDays) == takenAnnualDays ?
            String(describing: Int(takenAnnualDays)) : String(format: ViewConstants.halfDayFormat, takenAnnualDays)
        
        var remainingDays = totalDays - takenAnnualDays
        self.remainingDayNoLabel.text = floor(remainingDays) == remainingDays ?
            String(describing: Int(remainingDays)) : String(format: ViewConstants.halfDayFormat, remainingDays)
        
        var pendingDays = (leaveData.leavePending ?? 0.0) / workHours
        self.pendingDayNoLabel.text = floor(pendingDays) == pendingDays ?
            String(describing: Int(pendingDays)) : String(format: ViewConstants.halfDayFormat, pendingDays)
        
        var barWidth = self.progressBar.frame.width
        
        var approvedBarLen, sickBarLen, pendindgBarLen: CGFloat
        approvedBarLen = CGFloat(takenAnnualDays / totalDays) * barWidth
        pendindgBarLen = CGFloat((takenAnnualDays + pendingDays) / totalDays) * barWidth
        sickBarLen = 0
        
        self.approvedBarWidth.constant = approvedBarLen
        self.pendingBarWidth.constant = pendindgBarLen
        self.sicknessBarWidth.constant = sickBarLen
        
        totalDays = (trainingData.trainingTotal ?? 0.0) / workHours
        self.totalDayNoLabelTraining.text = (floor(totalDays) == totalDays ?
            String(describing: Int(totalDays)) : String(format: ViewConstants.halfDayFormat, totalDays)) + totalDaysLabelExtension
        
        takenAnnualDays = (trainingData.trainingTaken ?? 0.0) / workHours
        self.takenDayNoLabelTraining.text = floor(takenAnnualDays) == takenAnnualDays ?
            String(describing: Int(takenAnnualDays)) : String(format: ViewConstants.halfDayFormat, takenAnnualDays)
        
        remainingDays = totalDays - takenAnnualDays
        self.remainingDayNoLabelTraining.text = floor(remainingDays) == remainingDays ?
            String(describing: Int(remainingDays)) : String(format: ViewConstants.halfDayFormat, remainingDays)
        
        pendingDays = (trainingData.trainingPending ?? 0.0) / workHours
        self.pendingDayNoLabelTraining.text = floor(pendingDays) == pendingDays ?
            String(describing: Int(pendingDays)) : String(format: ViewConstants.halfDayFormat, pendingDays)
        
        barWidth = self.progressBarTraining.frame.width
        
        approvedBarLen = CGFloat(takenAnnualDays / totalDays) * barWidth
        pendindgBarLen = CGFloat((takenAnnualDays + pendingDays) / totalDays) * barWidth
        sickBarLen = 0
        
        self.approvedBarWidthTraining.constant = approvedBarLen
        self.pendingBarWidthTraining.constant = pendindgBarLen
        self.sicknessBarWidthTraining.constant = sickBarLen
    }
}
