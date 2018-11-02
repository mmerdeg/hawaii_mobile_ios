//
//  InputTableViewCell.swift
//  Hawaii
//
//  Created by Ivan Divljak on 9/24/18.
//  Copyright © 2018 Server. All rights reserved.
//

import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputReasonTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputReasonTextView.textColor = UIColor.lightGray
        inputReasonTextView.text = ViewConstants.requestReasonPlaceholder
        inputReasonTextView.delegate = self
    }
}

extension InputTableViewCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ViewConstants.requestReasonPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
}
