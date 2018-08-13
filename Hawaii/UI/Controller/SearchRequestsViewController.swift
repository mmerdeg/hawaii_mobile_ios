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
    
    func didSearch(from: Date, toDate: Date)
    
}

class SearchRequestsViewController: UIViewController {
    
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var toPicker: UIDatePicker!
    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var clickableView: UIView!
    
    weak var delegate: SearchDialogProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        delegate?.didSearch(from: fromPicker.date, toDate: toPicker.date)
    }
    
}
