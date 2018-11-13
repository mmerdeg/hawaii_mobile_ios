import UIKit

protocol SearchDialogProtocol: NSObjectProtocol {
    
    func dismissDialog()
    
    func didFilterBy(year: String, leave: Bool, sick: Bool, bonus: Bool)
}

class SearchRequestsViewController: UIViewController {
    
    @IBOutlet weak var bonusToggle: UISwitch!
  
    @IBOutlet weak var sickToggle: UISwitch!
   
    @IBOutlet weak var leaveToogle: UISwitch!
   
    @IBOutlet weak var clickableView: UIView!
   
    @IBOutlet weak var yearPicker: UIPickerView!
  
    @IBOutlet weak var yearLabel: UILabel!
  
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var leaveLabel: UILabel!
    
    @IBOutlet weak var sickLabel: UILabel!
    
    @IBOutlet weak var bonusLabel: UILabel!
    
    weak var delegate: SearchDialogProtocol?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var items: [Int] = []
    
    var startYear = 0
    
    var endYear = 0
   
    var leaveParameter = true
   
    var sickParameter = true
   
    var bonusParameter = true

    override func viewDidLoad() {
        super.viewDidLoad()
        bonusToggle.isOn = bonusParameter
        leaveToogle.isOn = leaveParameter
        sickToggle.isOn = sickParameter
        yearPicker.dataSource = self
        yearPicker.delegate = self
        
        backgroundView.backgroundColor = UIColor.primaryColor
        yearLabel.textColor = UIColor.primaryTextColor
        yearPicker.tintColor = UIColor.primaryTextColor
        
        yearLabel.text = LocalizedKeys.Filter.year.localized()
        filterButton.setTitle(LocalizedKeys.Filter.filter.localized(), for: .normal) 
        leaveLabel.text = LocalizedKeys.Request.leave.localized()
        sickLabel.text = LocalizedKeys.Request.sickness.localized()
        bonusLabel.text = LocalizedKeys.Request.bonus.localized()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
        var tempYear = startYear
        while tempYear <= endYear {
            self.items.append(tempYear)
            tempYear += 1
        }
        self.yearPicker.reloadAllComponents()
    }

    @objc func  dismissDialog() {
        delegate?.dismissDialog()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.didFilterBy(year: String(describing: items[yearPicker.selectedRow(inComponent: 0)]),
                              leave: leaveToogle.isOn, sick: sickToggle.isOn, bonus: bonusToggle.isOn)
    }
    
}

extension SearchRequestsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: items[row])
    }
 
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(describing: items[row]), attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }
}
