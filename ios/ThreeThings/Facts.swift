import Foundation
import SQLite

enum Magnitude: Int64 {
    case big
    case mid
    case small
}

private let thingTable = Table("thing")
private let versionTable = Table("version")
private let id = Expression<Int64>("id")
private let text = Expression<String>("text")
private let due = Expression<Date?>("due")
private let version = Expression<Int64>("version")
private let creation = Expression<Date>("creation")
private let magnitude = Expression<Int64>("magnitude")
private let done = Expression<Bool>("done")

struct Fact<T> {
    let primaryKey: Int64
    let fact: T
}

struct Thing {
    let text: String
    let creation: Date
    let due: Date?
    let magnitude: Magnitude
    let done: Bool
}

func thingOfRow(_ row: Row) -> Fact<Thing> {
    let thing = Thing(text: row[text], creation: row[creation], due: row[due], magnitude: Magnitude(rawValue: row[magnitude]).orElse(.big), done: row[done])
    return Fact(primaryKey: row[id], fact: thing)
}

func connect() throws -> Connection {
    if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        return try Connection("\(path)/facts.sqlite3")
    } else {
        fatalError("facts: unable to find document directory")
    }
}

func reset() {
    if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
        do {
            try FileManager.default.removeItem(atPath: "\(path)/facts.sqlite3")
        } catch {
            fatalError("facts: unable to remove db")
        }
    }
}

func listThings(_ db: Connection) throws -> [Fact<Thing>?] {
    let big = try! db.pluck(thingTable.filter(magnitude == 0).filter(done == false).limit(1).order(id.desc))
    let mid = try! db.pluck(thingTable.filter(magnitude == 1).filter(done == false).limit(1).order(id.desc))
    let small = try! db.pluck(thingTable.filter(magnitude == 2).filter(done == false).limit(1).order(id.desc))
    return [big, mid, small].map { rowMaybe in rowMaybe.map(thingOfRow) }
}

func insertThing(_ db: Connection, thing: Thing) throws {
    _ = try db.run(thingTable.insert(text <- thing.text, due <- thing.due, magnitude <- thing.magnitude.rawValue, done <- thing.done))
}

func markThingDone(_ db: Connection, thing: Fact<Thing>) throws {
    _ = try db.run(thingTable.filter(id == thing.primaryKey).update(done <- true))
}

class Facts {
    let db: Connection

    init(db: Connection) throws {
        self.db = db

        let migrations =
            [ ("make thing and version", _migrate1)
            , ("add creation date", _migrate2)
            , ("add magnitude", _migrate3)
            , ("add done", _migrate4)]
        let initialVersion = _version()
        let finalVersion = try migrations.dropFirst(Int(initialVersion)).reduce(initialVersion) {
            (v, tuple) in
            let (name, f) = tuple
            print("facts: trying migration #\(v + 1): \(name)")
            try f()
            return v + 1
        }
        _ = try db.run(versionTable.update(version <- finalVersion))
        print("facts: we are at version \(_version())")
    }

    func _version() -> Int64 {
        let count = try! db.scalar("select count(name) from sqlite_master") as! Int64
        if count == 0 {
            return 0
        } else {
            return try! db.scalar("select version from version") as! Int64
        }
    }

    func _migrate1() throws {
        try db.run(versionTable.create {
            t in
            t.column(version, primaryKey: true)
        })
        try db.run(thingTable.create {
            t in
            t.column(id, primaryKey: .autoincrement)
            t.column(text)
            t.column(due)
        })
        _ = try db.run(versionTable.insert(version <- 1))
    }

    func _migrate2() throws {
        let date = Date()
        try db.run(thingTable.addColumn(creation, defaultValue: date))
    }

    func _migrate3() throws {
        try db.run(thingTable.addColumn(magnitude, defaultValue: 0))
    }

    func _migrate4() throws {
        try db.run(thingTable.addColumn(done, defaultValue: false))
    }
}
