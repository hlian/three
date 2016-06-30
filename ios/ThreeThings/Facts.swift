//
//  Facts.swift
//  ThreeThings
//
//  Created by hao on 6/30/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import Foundation
import SQLite

func connect() throws -> Connection {
    if let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
        do {
            let db = try Connection("\(path)/facts.sqlite3")
            return db
        } catch {
            print("\(error)")
            fatalError("facts: unable to connect: ")
        }
    } else {
        fatalError("facts: unable to find document directory")
    }
}

class Facts {
    let db: Connection

    init(db: Connection) {
        self.db = db
        print("facts: we are at version \(_version())")
    }

    func _version() -> Int64 {
        let count = db.scalar("select count(name) from sqlite_master") as! Int64
        if count == 0 {
            return 0
        } else {
            return db.scalar("select version from version") as! Int64
        }
    }
}