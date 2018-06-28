//
//  RequestTypeViewController.swift
//  Hawaii
//
//  Created by Server on 6/27/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

protocol RequestDialogProtocol: NSObjectProtocol {
    func dismissDialog()
    func requestTypeClicked(requestType: RequestType)
}

class RequestTypeViewController: UIViewController {
    
    weak var delegate: RequestDialogProtocol?
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var clickableView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        clickableView.addGestureRecognizer(tap)
        dialogView.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    @objc func  dismissDialog() {
        delegate?.dismissDialog()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestTypeClicked(_ sender: Any) {
        guard let button = sender as? UIButton,
              let requestType = RequestType(rawValue: button.tag) else {
            return
        }
        print(requestType)
        delegate?.requestTypeClicked(requestType: requestType)
        dismiss(animated: true, completion: nil)
    }
}
