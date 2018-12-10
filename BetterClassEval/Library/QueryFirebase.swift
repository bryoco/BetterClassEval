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

    
    /// Instantiate Algolio
    /// Created by Rico
    init() {
        self.ref = Database.database().reference()
        self.client = Client(appID: "WLTP65SNR9", apiKey: "d41b5a90c41803f6948733ad827d9f19")
    }

    
    /// Query lecturers on Firebase.
    /// Deprecated.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - target: Database endpoint
    ///   - lecturer: Lecturer
    ///   - completion: Returns [ClassData]
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

    
    /// Query classes on Firebase. Deprecated.
    /// Deprecated.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - target: Database endpoint
    ///   - className: Class name
    ///   - completion: Returns [ClassData]
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
    

    /// Query anything from UW database on Algolio.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - anything: String
    ///   - completion: returns [ClassData]
    public func query(anything: String, completion: @escaping (([ClassData]) -> ())) {
        let index = self.client.index(withName: "uw")

        // Phase 1 - UW
        index.search(Query(query: anything), completionHandler: { (content, error) -> Void in
            if error == nil {
                let results = ((content!["hits"]!) as Any) as! [[String: Any]]
                var classData: [ClassData] = []

                for result in results {
                    classData.append(
                            ClassData(objectID: result["objectID"] as! String,
                                    className: result["class"] as! String,
                                    lecturer: result["lecturer"] as! String,
                                    quarter: result["quarter"] as! String,
                                    enrolled: Int(result["enrolled"] as! String)!,
                                    surveyed: Int(result["surveyed"] as! String)!,
                                    statistics: result["statistics"] as! [String: Any]))
                }
                completion(classData)
            }
        })
    }


    /// Query anything from both UW and user-submit database on Algolio.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - anything: String
    ///   - completion: returns [ClassData]
    public func queryAll(anything: String, completion: @escaping (([ClassData]) -> ())) {
        var index = self.client.index(withName: "uw")

        // Phase 1 - UW
        index.search(Query(query: anything), completionHandler: { (content, error) -> Void in
            if error == nil {
                let results = ((content!["hits"]!) as Any) as! [[String: Any]]
                var classData: [ClassData] = []

                for result in results {
                    classData.append(
                            ClassData(objectID: result["objectID"] as! String,
                                    className: result["class"] as! String,
                                    lecturer: result["lecturer"] as! String,
                                    quarter: result["quarter"] as! String,
                                    enrolled: Int(result["enrolled"] as! String)!,
                                    surveyed: Int(result["surveyed"] as! String)!,
                                    statistics: result["statistics"] as! [String: Any]))
                }

                // Phase 2 - Users
                index = self.client.index(withName: "userEval")
                index.search(Query(query: anything), completionHandler: { (content, error) -> Void in
                    if error == nil {
                        let results = ((content!["hits"]!) as Any) as! [[String: Any]]
                        var classData: [ClassData] = []

                        // {data: [ClassData], objectID: String}
                        for r in results {
                            // [ClassData]
                            for result in (r["data"] as! [[String : Any]]) {
                                classData.append(
                                        // Comply with Frank's data model
                                        ClassData(objectID: "",                                 // Doesn't have one
                                                className: result["class"] as! String,
                                                lecturer: result["lecturer"] as! String,
                                                quarter: result["quarter"] as! String,
                                                enrolled: 0,                                    // Ignored
                                                surveyed: 0,                                    // Ignored
                                                statistics: result["statistics"] as! [String: Any]))
                            }
                        }
                    }
                })
                completion(classData)
            }
        })
    }

    
    /// Upload user-submitted evaluation to Firebase.
    /// Deprecated.
    /// Created by Rico
    ///
    /// - Parameter map: raw map structure
    public func uploadEvaluation(map: [String: Any]) {
        self.ref.child("userEval").childByAutoId().setValue(map)
    }

    
    
    /// Upload user-submitted evaluation to Firebase.
    /// Deprecated.
    /// Created by Rico
    ///
    /// - Parameter classData: ClassData object
    public func uploadEvaluation(classData: ClassData) {
        self.ref.child("userEval").childByAutoId().setValue(classData.getSelf())
    }
    
    
    /// Helper method to query Firebase.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - q: Query
    ///   - completion: Returns [ClassData]
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

    
    
    /// Query every class from Firebase.
    /// Deprecated.
    /// Created by Rico
    func queryAllClasses() {
        let limit = 5
        var counter = 0
        var uniqueClass: Set = [""]
        ref.child("UW").queryOrdered(byChild: "class").observe(.value, with: { snapshots in
            for snapshot in snapshots.children {
                counter += 1

                let snap = (snapshot as! DataSnapshot).value as! [String: Any]
                let className = snap["class"] as! String // format

                if !uniqueClass.contains(className) {
                    uniqueClass.insert(className)
                }
                if counter >= limit {
                    break
                }
            }
        })
    }

    //["quarter": WI18,
    //"statistics": { "Amount Learned" = 0;
    //                "Course Content" = 0;
    //                "Grading Techniques" = 0;
    //                "Instructor's Contribution" = 0;
    //                "Instructor's Effectiveness" = 0;
    //                "Instructor's Interest" = 0;
    //                "The Course as a Whole" = 0;},
    //"class": INFO 330,
    //"lecturer": Joel Ross]
    /// Helper method to get user submissions from Algolio.
    /// Created by Rico
    ///
    /// - Parameters:
    ///   - userID: User ID from Firebase
    ///   - completion: returns [[ClassData]]
    func getUserSubmission(userID: String, completion: @escaping (([[String : Any]]) -> ())) {
        let index = self.client.index(withName: "userEval")
        index.getObject(withID: userID, completionHandler: { (content, error) in
            if error == nil {
                let results = ((content!["data"]!) as Any) as! [[String: Any]]
                completion(results)
            }
        })
    }
}

