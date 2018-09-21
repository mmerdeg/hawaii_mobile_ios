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
    
    func didFilter(year: String)
    
}

class SearchRequestsViewController: UIViewController {
    
    var items: [Int] = []
    
    @IBOutlet weak var clickableView: UIView!
    
    @IBOutlet weak var yearPicker: UIPickerView!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: SearchDialogProtocol?
    
    var requestUseCase: RequestUseCaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearPicker.dataSource = self
        yearPicker.delegate = self
        
        backgroundView.backgroundColor = UIColor.primaryColor
        yearLabel.textColor = UIColor.primaryTextColor
        yearPicker.tintColor = UIColor.primaryTextColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
        
        requestUseCase?.getAvailableRequestYears(completion: { yearsResponse in
            guard let startYear = yearsResponse.year?.first,
                  let endYear = yearsResponse.year?.last else {
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func  dismissDialog() {
        delegate?.dismissDialog()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.didFilter(year: String(describing: items[yearPicker.selectedRow(inComponent: 0)]))
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
