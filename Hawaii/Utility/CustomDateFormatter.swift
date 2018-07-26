import Foundation

class CustomDateFormatter: DateFormatter {
    
    let format = "yyyy-MM-dd hh:mm:ss Z"
    
    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
