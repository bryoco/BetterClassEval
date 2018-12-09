//
// Created by Rico Wang on 2018-12-08.
// Copyright (c) 2018 Group_5. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

class QueryFirebase {
    let ref: DatabaseReference

    init() {
        self.ref = Database.database().reference()
    }

    public func queryByLecturer(target: String, lecturer: String, completion: @escaping (([ClassData]) -> ())) {

        if target != "UW" && target != "userEval" {
            NSLog("Invalid target")
            return
        }

        let q = self.ref.child(target)
                .queryOrdered(byChild: "lecturer")
                .queryEqual(toValue: lecturer)

        self.query(q, completion: { result in completion(result) })
    }

    public func queryByClass(target: String, className: String, completion: @escaping (([ClassData]) -> ())) {

        if target != "UW" || target != "userEval" {
            NSLog("Invalid target")
            return
        }

        let q = self.ref.child(target)
                .queryOrdered(byChild: "class")
                .queryStarting(atValue: className)
                .queryEnding(atValue: className + "\u{F8FF}")

        self.query(q, completion: { result in completion(result) })
    }

    public func uploadEvaluation(map: [String : Any]) {
        self.ref.child("userEval").childByAutoId().setValue(map)
    }

    public func uploadEvaluation(classData: ClassData) {
        self.ref.child("userEval").childByAutoId().setValue(classData.getSelf())
    }

    private func query(_ q: DatabaseQuery, completion: @escaping (([ClassData]) -> Void)) {
        var results: [ClassData] = []
        q.observe(.value, with: { snapshots in
            NSLog("received results")
            var counter = 0
            for snapshot in snapshots.children {
                counter += 1
                let snap = snapshot as! DataSnapshot
                results.append(ClassData(snap))
            }
            NSLog("completed of size \(counter)")
            completion(results)
        })
    }

    func queryAllClasses() {
        let limit = 5
        var counter = 0
        var uniqueClass: Set = [""]
        ref.child("UW").queryOrdered(byChild: "class").observe(.value, with: { snapshots in
            for snapshot in snapshots.children {
                counter += 1

                let snap = (snapshot as! DataSnapshot).value as! [String : Any]
                let className = snap["class"] as! String // format

                if !uniqueClass.contains(className) { uniqueClass.insert(className)}
                if counter >= limit { break }
            }
        })
    }
}

