import Foundation

class DisplayedDateFormatter: DateFormatter {
    
    let format = "dd.MM.yyyy."
    
    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
