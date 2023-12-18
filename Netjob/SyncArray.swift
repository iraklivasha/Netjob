//
//  SyncArray.swift
//  Netjob
//
//  Created by Irakli Vashakidze on 06.12.23.
//

import Foundation

class SyncArray<T> {
    private var array: [T] = []
    private let accessQueue = DispatchQueue(label: "NetjobSynchronizedArrayAccess", attributes: .concurrent)

    func append(newElement: T) {

        self.accessQueue.async(flags:.barrier) {
            self.array.append(newElement)
        }
    }

    func removeAtIndex(index: Int) {

        self.accessQueue.async(flags:.barrier) {
            self.array.remove(at: index)
        }
    }

    var count: Int {
        var count = 0

        self.accessQueue.sync {
            count = self.array.count
        }

        return count
    }

    func first() -> T? {
        var element: T?

        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array[0]
            }
        }

        return element
    }
    
    func forEach(_ body: (T) throws -> Void) {
        self.accessQueue.sync {
            try? self.array.forEach(body)
        }
    }
    
    func removeAll() {
        self.accessQueue.sync {
            self.array.removeAll()
        }
    }

    subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags:.barrier) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.array[index]
            }

            return element
        }
    }
}
