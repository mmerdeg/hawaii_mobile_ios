import Foundation
import FMDB

class DatabaseInitializer {
    
    var databaseQueue: FMDatabaseQueue!
    
    var dispatchQueue: DispatchQueue!
    
    /**
     Initializes database queue and DAO objects.
     */
    func initialize(completion: @escaping (FMDatabaseQueue, DispatchQueue) -> Void) {
        
        let bundle = Bundle.main
        let dbName = "Hawaii.sqlite"
        let schemaName = "schema"
        let label = "database-queue"
        let sqlExtension = "sql"
        
        guard let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbName),
            let schemaUrl = bundle.url(forResource: schemaName, withExtension: sqlExtension),
            let schemaScript = (try? String(contentsOf: schemaUrl)) else {
                print("Error initializing schema.")
                fatalError()
        }
        databaseQueue = FMDatabaseQueue(path: fileUrl.absoluteString)
        dispatchQueue = DispatchQueue(
            label: label,
            qos: .background,
            autoreleaseFrequency: .workItem,
            target: nil
        )
        initializeDatabase(schemaScript: schemaScript) {
            completion(self.databaseQueue, self.dispatchQueue)
        }
    }
    
    func initializeDatabase(schemaScript: String, completion: @escaping () -> Void) {
        databaseQueue?.inDatabase { database in
            let result = database.executeStatements(schemaScript)
            print("result", result)
            completion()
        }
    }
    
}
