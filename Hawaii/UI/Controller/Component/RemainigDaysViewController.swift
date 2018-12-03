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
    
    @IBOutlet weak var approvedBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var pendingBarWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sicknessBarWidth: NSLayoutConstraint!
    
    var mainLabelText: String?
    
    var userUseCase: UserUseCase?
    
    var user: User?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLabel.text = mainLabelText ?? ""
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
    }

    func getData() {
        
        let leaveLabel = LocalizedKeys.RemainingDays.leave.localized()
        let trainingLabel = LocalizedKeys.RemainingDays.training.localized()
        
        startActivityIndicatorSpinner()
        
        mainLabel.text = mainLabelText
        
        userUseCase?.getUser(completion: { response in
            guard let success = response?.success else {
                self.stopActivityIndicatorSpinner()
                return
            }
            if !success {
                self.handleResponseFaliure(message: response?.message)
                return
            }
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
            var total = 0.0, taken = 0.0, pending = 0.0
            
            switch self.mainLabelText {
            case leaveLabel:
                total = Double(annual + carriedOver + bonus + manualAdjust)
                taken = Double(takenAnnual)
                pending = Double(pendingAnnual)
            case trainingLabel:
                total = Double(training)
                taken = Double(takenTraining)
                pending = Double(trainingPending)
            default:
                total = Double(annual + carriedOver + bonus + manualAdjust)
                taken = Double(takenAnnual)
                pending = Double(pendingAnnual)
            }
            
            self.populateViewData(total: total, taken: taken, pending: pending)
            self.stopActivityIndicatorSpinner()
        })
    }
    
    func populateViewData(total: Double, taken: Double, pending: Double) {
      
        let workHours = 8.0
        
        let totalDaysLabelExtension = " " + LocalizedKeys.RemainingDays.days.localized().capitalized
        
        let totalDays = total / workHours
        self.totalDayNoLabel.text = (floor(totalDays) == totalDays ?
            String(describing: Int(totalDays)) : String(format: ViewConstants.halfDayFormat, totalDays)) + totalDaysLabelExtension
        
        let takenAnnualDays = taken / workHours
        self.takenDayNoLabel.text = floor(takenAnnualDays) == takenAnnualDays ?
            String(describing: Int(takenAnnualDays)) : String(format: ViewConstants.halfDayFormat, takenAnnualDays)
        
        let remainingDays = totalDays - takenAnnualDays
        self.remainingDayNoLabel.text = floor(remainingDays) == remainingDays ?
            String(describing: Int(remainingDays)) : String(format: ViewConstants.halfDayFormat, remainingDays)
        
        let pendingDays = pending / workHours
        self.pendingDayNoLabel.text = floor(pendingDays) == pendingDays ?
            String(describing: Int(pendingDays)) : String(format: ViewConstants.halfDayFormat, pendingDays)
        
        let barWidth = self.progressBar.frame.width
        
        var approvedBarLen, sickBarLen, pendindgBarLen: CGFloat
        approvedBarLen = CGFloat(takenAnnualDays / totalDays) * barWidth
        pendindgBarLen = CGFloat((takenAnnualDays + pendingDays) / totalDays) * barWidth
        sickBarLen = 0
        
        self.approvedBarWidth.constant = approvedBarLen
        self.pendingBarWidth.constant = pendindgBarLen
        self.sicknessBarWidth.constant = sickBarLen
    }
}
