//
//  Facts.swift
//  ThreeThings
//
//  Created by hao on 6/30/16.
//  Copyright © 2016 ThreeThings. All rights reserved.
//

import Foundation
import SQLite

let Thing = Table("thing")
let Version = Table("version")
let id = Expression<Int64>("id")
let text = Expression<String>("text")
let due = Expression<NSDate?>("due")
let version = Expression<Int64>("version")

func connect() throws -> Connection {
    if let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
        return try Connection("\(path)/facts.sqlite3")
    } else {
        fatalError("facts: unable to find document directory")
    }
}

func reset() {
    if let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first {
        do {
            try NSFileManager.defaultManager().removeItemAtPath("\(path)/facts.sqlite3")
        } catch {
            fatalError("facts: unable to remove db")
        }
    }
}

class Facts {
    let db: Connection

    init(db: Connection) throws {
        self.db = db

        let migrations =
            [("make thing and version", _migrate1)]
        let initialVersion = _version()
        let finalVersion = try migrations.dropFirst(Int(initialVersion)).reduce(initialVersion) {
            (v, tuple) in
            let (name, f) = tuple
            print("facts: trying migration #\(v + 1): \(name)")
            try f()
            return v + 1
        }
        try db.run(Version.update(version <- finalVersion))
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

    func _migrate1() throws {
        try db.run(Version.create {
            t in
            t.column(version, primaryKey: true)
        })
        try db.run(Thing.create {
            t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(text)
            t.column(due)
        })
        try db.run(Version.insert(version <- 1))
    }
}