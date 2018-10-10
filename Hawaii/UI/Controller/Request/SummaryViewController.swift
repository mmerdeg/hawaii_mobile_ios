//
//  SummaryViewController.swift
//  Hawaii
//
//  Created by Server on 10/9/18.
//  Copyright © 2018 Server. All rights reserved.
//

import Foundation
import UIKit

class SummaryViewController: BaseViewController {
    
    @IBOutlet weak var requestTitle: UILabel!
    
    @IBOutlet weak var requestImageFrame: UIView!
    
    @IBOutlet weak var requestImage: UIImageView!
    
    @IBOutlet weak var datesLabel: UILabel!
    
    @IBOutlet weak var leaveRequestedLabel: UILabel!
    
    @IBOutlet weak var leaveRemainingLabel: UILabel!
    
    @IBOutlet weak var leaveTypeLabel: UILabel!
    
    @IBOutlet weak var leaveReasonLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var datesRequiredTitle: UILabel!
    
    @IBOutlet weak var leaveRequestedTitle: UILabel!
    
    @IBOutlet weak var leaveRemainingTitle: UILabel!
    
    @IBOutlet weak var leaveTypeTitle: UILabel!
    
    @IBOutlet weak var reasonTitle: UILabel!
    
    @IBOutlet weak var leaveRemainingConstraintTop: NSLayoutConstraint!
    
    var remainingDaysNo: String?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var request: Request?
    
    weak var requestUpdateDelegate: RequestUpdateProtocol?
    
    lazy var addRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Submit", style: UIBarButtonItemStyle.done, target: self, action: #selector(addRequest))
        item.tintColor = UIColor.primaryTextColor
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let request = request,
            let imageUrl = request.absence?.iconUrl,
            var color = request.requestStatus?.backgoundColor,
            let startDate = request.days?.first?.date,
            let endDate = request.days?.last?.date,
            let dayNo = request.days?.count,
            let leaveType = request.absence?.name,
            let absenceType = request.absence?.absenceType,
            let remainingDaysString = remainingDaysNo,
            let remainingDays = Int(remainingDaysString)
        else {
            return
        }
        self.navigationItem.rightBarButtonItem = addRequestItem
        
        color = absenceType == AbsenceType.sick.rawValue ? UIColor.sickColor : color
        reasonTitle.textColor = UIColor.primaryTextColor
        datesRequiredTitle.textColor = UIColor.primaryTextColor
        leaveRequestedTitle.textColor = UIColor.primaryTextColor
        leaveTypeTitle.textColor = UIColor.primaryTextColor
        leaveRemainingTitle.textColor = UIColor.primaryTextColor
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy."
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        datesLabel.text = start == end ? start : start + " - " + end
        datesLabel.textColor = UIColor.primaryTextColor
        
        cardView.backgroundColor = UIColor.lightPrimaryColor
        
        requestImage.kf.setImage(with: URL(string: Constants.baseUrl + "/" + imageUrl))
        requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
        requestImage.tintColor = UIColor.primaryColor
        requestImage.backgroundColor = color
        requestImage.layer.cornerRadius = requestImage.frame.height / 2
        requestImage.layer.masksToBounds = true
        requestImageFrame.backgroundColor = color
        requestImageFrame.layer.cornerRadius = requestImageFrame.frame.height / 2
        requestImageFrame.layer.masksToBounds = true
        
        leaveRequestedLabel.text = String(dayNo) + " day(s)"
        leaveRequestedLabel.textColor = UIColor.primaryTextColor
        
        leaveTypeLabel.text = leaveType
        leaveTypeLabel.textColor = UIColor.primaryTextColor
        
        leaveReasonLabel.text = request.reason
        leaveReasonLabel.textColor = UIColor.primaryTextColor
        
        if absenceType == AbsenceType.bonus.rawValue {
            requestTitle.text = "Bonus request"
            hideRemainingDays()
        } else if absenceType == AbsenceType.sick.rawValue {
            requestTitle.text = "Sickness request"
            hideRemainingDays()
        } else {
            requestTitle.text = "Leave request"
            leaveRemainingLabel.text = String(remainingDays - dayNo) + " day(s)"
            leaveRemainingLabel.textColor = UIColor.primaryTextColor
        }
        requestTitle.textColor = UIColor.primaryTextColor
    }
    
    func hideRemainingDays() {
        leaveRemainingTitle.isHidden = true
        leaveRemainingLabel.isHidden = true
        leaveRemainingConstraintTop.constant = 0
        leaveRemainingLabel.frame = CGRect(x: leaveRemainingLabel.frame.minX, y: leaveRemainingLabel.frame.minY,
                                           width: leaveRemainingLabel.frame.width, height: 0)
        leaveRemainingTitle.frame = CGRect(x: leaveRemainingTitle.frame.minX, y: leaveRemainingTitle.frame.minY,
                                           width: leaveRemainingTitle.frame.width, height: 0)
//        leaveRemainingLabel.frame.size.height = 0
//        leaveRemainingTitle.frame.size.height = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func addRequest() {
        guard let request = request,
              let requestUseCase = requestUseCase else {
            return
        }
        
        self.startActivityIndicatorSpinner()
        
        requestUseCase.add(request: request) { requestResponse in
            guard let success = requestResponse.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if success {
                guard let request = requestResponse.item else {
                    self.stopActivityIndicatorSpinner()
                    return
                }
                self.requestUpdateDelegate?.didAdd(request: request)
                guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else {
                    self.navigationController?.popViewController(animated: true)
                    self.stopActivityIndicatorSpinner()
                    return
                }
                self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                self.stopActivityIndicatorSpinner()
            } else {
                ViewUtility.showAlertWithAction(title: "Error", message: requestResponse.message ?? "",
                                                viewController: self, completion: { _ in
                                                    self.stopActivityIndicatorSpinner()
                })
            }
        }
    }
    
}
