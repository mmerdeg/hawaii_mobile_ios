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
    
    @IBOutlet weak var dividor: UIView!
    
    @IBOutlet weak var datesRequiredTitle: UILabel!
    
    @IBOutlet weak var leaveRequestedTitle: UILabel!
    
    @IBOutlet weak var leaveRemainingTitle: UILabel!
    
    @IBOutlet weak var leaveTypeTitle: UILabel!
    
    @IBOutlet weak var reasonTitle: UILabel!
    
    @IBOutlet weak var leaveRemainingConstraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var leaveRemainingLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var leaveRemainingTitleHeight: NSLayoutConstraint!
    
    var remainingDaysNo: String?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var request: Request?
    
    weak var requestUpdateDelegate: RequestUpdateProtocol?
    
    lazy var addRequestItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: LocalizedKeys.Summary.submit.localized(), style: UIBarButtonItemStyle.done,
                                   target: self, action: #selector(addRequest))
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
            let leaveType = request.absence?.name,
            let days = request.days,
            let absenceType = request.absence?.absenceType
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
        requestTitle.textColor = UIColor.primaryTextColor
        leaveRequestedLabel.textColor = UIColor.primaryTextColor
        leaveReasonLabel.textColor = UIColor.primaryTextColor
        leaveTypeLabel.textColor = UIColor.primaryTextColor
        leaveRemainingLabel.textColor = UIColor.primaryTextColor
        dividor.backgroundColor = UIColor.primaryColor
            
        cardView.backgroundColor = UIColor.lightPrimaryColor
        
        leaveTypeLabel.text = leaveType
        leaveReasonLabel.text = request.reason
        
        leaveTypeTitle.text = LocalizedKeys.Summary.leaveType.localized()
        leaveRemainingTitle.text = LocalizedKeys.Summary.leaveRemaining.localized()
        leaveRequestedTitle.text = LocalizedKeys.Summary.leaveRequested.localized()
        datesRequiredTitle.text = LocalizedKeys.Summary.datesRequested.localized()
        reasonTitle.text = LocalizedKeys.Summary.reason.localized()
        
        handleAbsenceType(absenceType: absenceType)
        handleRemainingDays(absenceType: absenceType, days: days)
        handleDatesTaken(startDate: startDate, endDate: endDate)
        displayImage(color: color, imageUrl: imageUrl)
    }
    
    func displayImage(color: UIColor, imageUrl: String) {
        requestImage.kf.setImage(with: URL(string: ViewConstants.baseUrl + "/" + imageUrl))
        requestImage.image = requestImage.image?.withRenderingMode(.alwaysTemplate)
        requestImage.tintColor = UIColor.statusIconColor
        requestImage.backgroundColor = color
        requestImage.layer.cornerRadius = requestImage.frame.height / 2
        requestImage.layer.masksToBounds = true
        requestImageFrame.backgroundColor = color
        requestImageFrame.layer.cornerRadius = requestImageFrame.frame.height / 2
        requestImageFrame.layer.masksToBounds = true
    }
    
    func handleAbsenceType(absenceType: String) {
        if absenceType == AbsenceType.bonus.rawValue {
            requestTitle.text = LocalizedKeys.Request.bonusRequest.localized()
            hideRemainingDays()
        } else if absenceType == AbsenceType.sick.rawValue {
            requestTitle.text = LocalizedKeys.Request.sicknessRequest.localized()
            hideRemainingDays()
        } else {
            requestTitle.text = LocalizedKeys.Request.leaveRequest.localized()
        }
    }
    
    func handleDatesTaken(startDate: Date, endDate: Date) {
        let formatter = DisplayedDateFormatter()
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        datesLabel.text = start == end ? start : start + " - " + end
        datesLabel.textColor = UIColor.primaryTextColor
    }
    
    func hideRemainingDays() {
        leaveRemainingTitle.isHidden = true
        leaveRemainingLabel.isHidden = true
        leaveRemainingConstraintTop.constant = 0
        leaveRemainingLabelHeight.constant = 0
        leaveRemainingTitleHeight.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func handleRemainingDays(absenceType: String, days: [Day]) {
        
        let daysLabelExtension = LocalizedKeys.Summary.days.localized()
        
        guard let remainingDaysString = remainingDaysNo else {
            return
        }
        let half = days.contains { day -> Bool in
            day.duration != DurationType.fullday
        }
        let requestedDays = Double(days.count) - (half ? 0.5 : 0)
        
        let remainingDays = absenceType == AbsenceType.nonDecuted.rawValue ? Double(remainingDaysString) ?? 0 :
            (Double(remainingDaysString) ?? 0) - requestedDays
        
        leaveRemainingLabel.text = (floor(remainingDays) == remainingDays ?
            String(describing: Int(remainingDays)) : String(format: ViewConstants.halfDayFormat, remainingDays)) + daysLabelExtension
        
        leaveRequestedLabel.text = (floor(requestedDays) == requestedDays ?
            String(describing: Int(requestedDays)) : String(format: ViewConstants.halfDayFormat, requestedDays)) + daysLabelExtension
    }
    
    @objc func addRequest() {
        self.view.isUserInteractionEnabled = false
        guard let request = request,
              let requestUseCase = requestUseCase else {
            self.view.isUserInteractionEnabled = true
            return
        }
        
        self.startActivityIndicatorSpinner()
        
        requestUseCase.add(request: request) { requestResponse in
            guard let success = requestResponse.success else {
                self.stopActivityIndicatorSpinner()
                self.view.isUserInteractionEnabled = true
                return
            }
            if !success {
                self.handleResponseFaliure(message: requestResponse.message)
                self.view.isUserInteractionEnabled = true
                return
            }
            guard let request = requestResponse.item else {
                self.stopActivityIndicatorSpinner()
                self.view.isUserInteractionEnabled = true
                return
            }
            self.requestUpdateDelegate?.didAdd(request: request)
            guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else {
                self.navigationController?.popViewController(animated: true)
                self.stopActivityIndicatorSpinner()
                self.view.isUserInteractionEnabled = true
                return
            }
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            self.stopActivityIndicatorSpinner()
            self.view.isUserInteractionEnabled = true
        }
    }
    
}
