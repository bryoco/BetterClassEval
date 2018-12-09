//
// Created by Rico Wang on 2018-12-08.
// Copyright (c) 2018 Group_5. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import InstantSearchClient

class QueryFirebase {
    let ref: DatabaseReference
    let client: Client

    init() {
        self.ref = Database.database().reference()
        self.client = Client(appID: "WLTP65SNR9", apiKey: "d41b5a90c41803f6948733ad827d9f19")
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

    public func query(anything: String, completion: @escaping (([ClassData]) -> ())) {
        let index = self.client.index(withName: "uw")
        index.search(Query(query: anything), completionHandler: { (content, error) -> Void in
            if error == nil {
                let results = ((content!["hits"]!) as Any) as! [[String : Any]]
                var classData: [ClassData] = []

                var counter = 0
                for result in results {
                    counter += 1

                    classData.append(
                            ClassData(objectID: result["objectID"] as! String,
                                      className: result["class"] as! String,
                                      lecturer: result["lecturer"] as! String,
                                      quarter: result["quarter"] as! String,
                                      enrolled: Int(result["enrolled"] as! String)!,
                                      surveyed: Int(result["surveyed"] as! String)!,
                                      statistics: result["statistics"] as! [String : Any]))
                }
                completion(classData)
            }
        })
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

