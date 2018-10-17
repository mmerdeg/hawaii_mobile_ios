import Foundation

class CustomDateFormatter: DateFormatter {
    
    let format = "yyyy-MM-dd hh:mm:ss Z"
    let zone = "UTC"
    
    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
