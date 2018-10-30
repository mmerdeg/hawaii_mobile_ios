//
//  SearchRequestsViewController.swift
//  Hawaii
//
//  Created by Server on 8/13/18.
//  Copyright © 2018 Server. All rights reserved.
//

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
    
    weak var delegate: SearchDialogProtocol?
    
    var requestUseCase: RequestUseCaseProtocol?
    
    var items: [Int] = []
   
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
        
        requestUseCase?.getAvailableRequestYears(completion: { yearsResponse in
            guard let success = yearsResponse.success else {
                return
            }
            if !success {
                ViewUtility.showAlertWithAction(title: ViewConstants.errorDialogTitle, message: yearsResponse.message ?? "",
                                                viewController: self, completion: { _ in
                })
                return
            }
            guard let startYear = yearsResponse.item?.first,
                  let endYear = yearsResponse.item?.last else {
                    return
            }
            var tempYear = startYear
            while tempYear <= endYear {
                self.items.append(tempYear)
                tempYear += 1
            }
            self.yearPicker.reloadAllComponents()
        })
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
