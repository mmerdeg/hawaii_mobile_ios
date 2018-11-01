import Foundation

class RequestDateFormatter: DateFormatter {
    
    let format = "yyyy-MM-dd"

    override init() {
        super.init()
        dateFormat = format
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
