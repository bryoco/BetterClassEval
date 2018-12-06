//
// Created by Rico Wang on 2018-12-03.
// Copyright (c) 2018 Group_5. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class Request {

    public func login(_ user: Authentication, completion: @escaping (() -> ())) {
        let url: String = "https://www.washington.edu/cec/a/AA101A2098.html"

        let cstorage = HTTPCookieStorage.shared
        if let cookies = cstorage.cookies(for: URL(string: "https://weblogin.washington.edu")!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }

        if let cookies = cstorage.cookies(for: URL(string: "https://www.washington.edu")!) {
            for cookie in cookies {
                cstorage.deleteCookie(cookie)
            }
        }

        // Step 1
        user.webLoginFirstKiss(completion: {
            NSLog("step 1")
            // Step 2
            user.weblogin(completion: {
                NSLog("step 2")
                // Step 3
                user.getCoursePage(url, completion: {
                    NSLog("step 3")
                    // Step 4, gets pubcookie_g
                    user.webloginRedirect(url, completion: {
                        NSLog("step 4")
                        completion()
                    })
                })
            })
        })

    }

    /// Gets URL list from the package
    /// Reads 10 links from 10.txt by default.
    /// See /src/ for available files.
    public func readLocalURL(_ file: String = "10") -> [String] {

        // Target URL list
        var urlList: [String] = []

        // Load local URL list
        if let path = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                urlList = content.components(separatedBy: .newlines)
            } catch {
                NSLog("Unspecified error")
            }
        }

        return urlList

    }

    /// Gets class evaluation data from a URL
    public func requestEvalFromURL(user: Authentication, url: String, completion: @escaping (([String: Any])) -> ()) {

        // If cookies are not valid, do everything
        if !user.cookiesAreValid() {
            login(user, completion: {})
        }

        // Step 5: Do whatever with pubcookie_g
        user.getCoursePageWithCookie(url, completion: { result in
            HTMLParser().getStatsFromPage(result, completion: { result in
//                NSLog(result.debugDescription)
                completion(result)
            })
        })

    }

    /// Gets class evaluation data from a list of URLs
    public func requestEvalFromList(user: Authentication, urlList: [String], completion: @escaping () -> ()) {

        /*
        To any poor souls whom try to maintain this spaghetti, you have my warning - don't.

        Just use it.

        This service literally retires on Dec. 30, 2018 and I am not intended to maintain it unless they switch to
        oauth or something similar.

        The complete flow of requesting a review page is as followed:
        1. Issue a GET request to UW Weblogin, get the hidden fields
        2. POST user creds and the hidden fields from Step 1 to UW Weblogin to *actually* log in,
           record pubcookie_l from response
        3. GET the review page, record pubcookie_g_req and relay_url from response
        4. POST to UW Weblogin with [Cookie: pubcookie_l] as header, and pubcookie_g_req=?&relay_url=? as body,
           record pubcookie_g from the hidden fields from response
        5. GET the review page with [Cookie: pubcookie_g] as header, and parse the resulting HTML
        */

        // File writing
        let file = "eval.txt"
        var fileURL: URL? = nil

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(file)
            NSLog("fileURL: \(fileURL.debugDescription)")
        }

        clearFile(fileURL!)

        // Set counter to sleep()
        var counter: Int = 0

        // Simplified flow
        for url in urlList {

            // Number of HTTP request
            counter += 1
            if !user.cookiesAreValid() {
                self.login(user, completion: {})
            }

            if counter % 100 == 0 {
                sleep(1)
            }

            // Cookies are invalidated at 967th request.
            // Re-login every 500 requests
//            let group = DispatchGroup()
//            group.enter()
//            if counter % 10 == 0 {
//                DispatchQueue(label: "sequential").sync(execute: {
//                    self.login(user, completion: {
//                        NSLog("logged in")
//                        group.leave()
//                    })
//                    NSLog("done logging in")
//                })
//            } else {
//                group.leave()
//            }
//
//            group.wait()
//            NSLog(String(counter))

            if counter % 500 == 0 {
                self.login(user, completion: {
                    user.getCoursePageWithCookie(url, completion: { result in
                        HTMLParser().getStatsFromPage(result, completion: { result in

                            guard let fileHandle = try? FileHandle(forWritingTo: fileURL!) else {
                                NSLog("Cannot write file!!!")
                                return
                            }

                            NSLog(result.debugDescription)
                            fileHandle.seekToEndOfFile()
                            fileHandle.write(Data(result.debugDescription.utf8))
                            fileHandle.write("\n".data(using: .utf8)!)
                            fileHandle.closeFile()
                        })
                    })
                })
            } else {
                user.getCoursePageWithCookie(url, completion: { result in
                    HTMLParser().getStatsFromPage(result, completion: { result in

                        guard let fileHandle = try? FileHandle(forWritingTo: fileURL!) else {
                            NSLog("Cannot write file!!!")
                            return
                        }

                        NSLog(result.debugDescription)
                        fileHandle.seekToEndOfFile()
                        fileHandle.write(Data(result.debugDescription.utf8))
                        fileHandle.write("\n".data(using: .utf8)!)
                        fileHandle.closeFile()
                    })
                })
            }

            // Do whatever with pubcookie_g
//            user.getCoursePageWithCookie(url, completion: { result in
//                HTMLParser().getStatsFromPage(result, completion: { result in
//
//                    guard let fileHandle = try? FileHandle(forWritingTo: fileURL!) else {
//                        NSLog("Cannot write file!!!")
//                        return
//                    }
//
//                    NSLog(result.debugDescription)
//                    fileHandle.seekToEndOfFile()
//                    fileHandle.write(Data(result.debugDescription.utf8))
//                    fileHandle.write("\n".data(using: .utf8)!)
//                    fileHandle.closeFile()
//                })
//            })

            // Complete flow - Does everything for every quest
//        for url in urlList {
//            // Step 1
//            user.webLoginFirstKiss(completion: {
//                // Step 2
//                user.weblogin(completion: {
//                    // Step 3
//                    user.getCoursePage(url, completion: {
//                        // Step 4, gets pubcookie_g
//                        user.webloginRedirect(url, completion: {
//                            user.getCoursePageWithCookie(url, completion: { result in
//                                HTMLParser().getStatsFromPage(result, completion: { result in
//                                    NSLog(result.debugDescription)
//                                    resultList.append(result)})})})})})})
//        }
//            completion(resultList)
        }

        completion()
    }
}


// TODO: Clean this

// TODO: probably needs a DispatchQueue here?
//        getEvalList(urlList: urlList, completion: { result in
//            NSLog("getting resultlist back")
//            NSLog(result.debugDescription)
//        })

// Manually getting local data
//        let chars: [Character] = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
//                                  "q", "r", "s", "t", "u", "v", "w"]
//        var urlList: [String] = []
//        for char in chars {
//            urlList.append("http://localhost:8123/" + String(char) + "-toc.html")
//        }

// Getting all class URLs from ToC pages
//        for url in urlList {
//            HTMLParser().getAllClasses(url, completion: { result in
//                let hrefs: [[String : String]] = result
//
//                for href in hrefs {
//                    let link: String = href["link"]!
//                    NSLog(link)
//// Getting course pages
////                user.getCoursePageWithCookie(link, completion: { result in
////                    HTMLParser().getStatsFromPage(result, completion: { result in
////                        NSLog(result.debugDescription) })
////                })
//                }
//
//            })
//        }