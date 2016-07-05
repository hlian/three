import Foundation
import SQLite

private let thingTable = Table("thing")
private let versionTable = Table("version")
private let id = Expression<Int64>("id")
private let text = Expression<String>("text")
private let due = Expression<NSDate?>("due")
private let version = Expression<Int64>("version")
private let creation = Expression<NSDate>("creation")

struct Fact<T> {
    let primaryKey: Int64
    let fact: T
}

struct Thing {
    let text: String
    let creation: NSDate
    let due: NSDate?
}

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

func insertThing(db: Connection, thing: Thing) throws {
    try db.run(thingTable.insert(text <- thing.text, due <- thing.due))
}

class Facts {
    let db: Connection

    init(db: Connection) throws {
        self.db = db

        let migrations =
            [ ("make thing and version", _migrate1)
            , ("add creation date", _migrate2)]
        let initialVersion = _version()
        let finalVersion = try migrations.dropFirst(Int(initialVersion)).reduce(initialVersion) {
            (v, tuple) in
            let (name, f) = tuple
            print("facts: trying migration #\(v + 1): \(name)")
            try f()
            return v + 1
        }
        try db.run(versionTable.update(version <- finalVersion))
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
        try db.run(versionTable.create {
            t in
            t.column(version, primaryKey: true)
        })
        try db.run(thingTable.create {
            t in
            t.column(id, primaryKey: .Autoincrement)
            t.column(text)
            t.column(due)
        })
        try db.run(versionTable.insert(version <- 1))
    }

    func _migrate2() throws {
        let date = NSDate()
        try db.run(thingTable.addColumn(creation, defaultValue: date))
    }
}