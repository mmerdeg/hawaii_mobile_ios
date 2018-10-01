//
//  DatabaseInitializer.swift
//  Hawaii
//
//  Created by Server on 10/1/18.
//  Copyright © 2018 Server. All rights reserved.
//

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
        guard let fileUrl = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Hawaii.sqlite"),
            let schemaUrl = bundle.url(forResource: "schema", withExtension: Constants.sqlExtension),
            let schemaScript = (try? String(contentsOf: schemaUrl)) else {
                print("Error initializing schema.")
                fatalError()
        }
        databaseQueue = FMDatabaseQueue(path: fileUrl.absoluteString)
        dispatchQueue = DispatchQueue(
            label: "database-queue",
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
