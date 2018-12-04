//
// Created by Rico Wang on 2018-12-03.
// Copyright (c) 2018 Group_5. All rights reserved.
//

import Foundation

// write NSLog to disk
public func writeLogToDisk(fileName: String) {
    let docDirectory: NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
    let logPath = docDirectory.appendingPathComponent("\(fileName).txt")
    NSLog(logPath)
    freopen(logPath.cString(using: String.Encoding.utf8)!, "a+", stderr)

    NSLog("******************************************************")
    NSLog("**************** STARTING NEW SESSION ****************")
    NSLog("******************************************************")

}