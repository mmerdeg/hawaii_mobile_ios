import UIKit

class InputTableViewCell: UITableViewCell {

    @IBOutlet weak var inputReasonTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputReasonTextView.textColor = UIColor.lightGray
        inputReasonTextView.text = LocalizedKeys.Request.reasonPlaceholder.localized()
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
            textView.text = LocalizedKeys.Request.reasonPlaceholder.localized()
            textView.textColor = UIColor.lightGray
        }
    }
}
