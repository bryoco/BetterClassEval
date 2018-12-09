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

    public func queryByLecturer(_ lecturer: String, completion: @escaping (([ClassData]) -> ())) {

        let q = ref.child("UW")
                .queryOrdered(byChild: "lecturer")
                .queryEqual(toValue: lecturer)

        self.query(q, completion: { result in completion(result) })

//        var results: [classData] = []
//        q.observe(.value, with: { snapshots in
//            for snapshot in snapshots.children {
//                let snap = (snapshot as! DataSnapshot).value as! NSDictionary
//                results.append(classData(data: snap))
//            }
//            completion(results)
//        })
    }

    public func queryByClass(_ className: String, completion: @escaping (([ClassData]) -> ())) {

        let q = ref.child("UW")
                .queryOrdered(byChild: "class")
                .queryEqual(toValue: className)

        self.query(q, completion: { result in completion(result) })


//        var results: [classData] = []
//        q.observe(.value, with: { snapshots in
//            for snapshot in snapshots.children {
//                let snap = (snapshot as! DataSnapshot).value as! NSDictionary
//                results.append(classData(data: snap))
//            }
//            completion(results)
//        })
    }

    private func query(_ q: DatabaseQuery, completion: @escaping (([ClassData]) -> Void)) {
        var results: [ClassData] = []
        q.observe(.value, with: { snapshots in
            for snapshot in snapshots.children {
//                let snap = (snapshot as! DataSnapshot).value as! NSDictionary
                let snap = snapshot as! DataSnapshot
                results.append(ClassData(snap))
            }
            completion(results)
        })
    }
}

