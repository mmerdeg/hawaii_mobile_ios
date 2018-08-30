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
    
    let years = ["2016", "2017", "2018", "2019"]
    
    @IBOutlet weak var clickableView: UIView!
    
    @IBOutlet weak var yearPicker: UIPickerView!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    weak var delegate: SearchDialogProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        yearPicker.dataSource = self
        yearPicker.delegate = self
        
        backgroundView.backgroundColor = UIColor.primaryColor
        yearLabel.textColor = UIColor.primaryTextColor
        yearPicker.tintColor = UIColor.primaryTextColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
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
        delegate?.didFilter(year: years[yearPicker.selectedRow(inComponent: 0)])
    }
    
}

extension SearchRequestsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return years[row]
    }
 
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: years[row], attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
    }

}
