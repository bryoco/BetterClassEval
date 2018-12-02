//
//  HTMLParser.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/26/18.
//  Copyright © 2018 Group_5. All rights reserved.
//
// To any poor souls whom try to maintain this spaghetti, you have my warning - don't.
//
// Just use it.
//
// This service literally retires on Dec. 30, 2018 and I am not intended to maintain it unless they switch to
// oauth or something similar.
//
// The complete flow of requesting a review page is as followed:
// 1. Issue a GET request to UW Weblogin, get the hidden fields
// 2. POST user creds and the hidden fields from Step 1 to UW Weblogin to *actually* log in,
//    record pubcookie_l from response
// 3. GET the review page, record pubcookie_g_req and relay_url from response
// 4. POST to UW Weblogin with [Cookie: pubcookie_l] as header, and pubcookie_g_req=?&relay_url=? as body,
//    record pubcookie_g from the hidden fields from response
// 5. GET the review page with [Cookie: pubcookie_g] as header, and parse the resulting HTML
//

import Foundation
import SwiftSoup
import Alamofire

public class Authentication {

    let username: String
    let password: String
    let timeCreation = NSDate().timeIntervalSince1970 // Cookies last for 8 hours

    var pubcookie_g: String
    var pubcookie_g_req: String
    var pubcookie_l: String
    var redirect_url: String
    
    var firstKiss: [String : String]

    public init(username: String, password: String) {

        self.username = username
        self.password = password

        self.pubcookie_g = ""
        self.pubcookie_l = ""
        self.pubcookie_g_req = ""
        self.redirect_url = ""

        self.firstKiss = [:]
    }

    public func ifCookiesValid() -> Bool {
        return NSDate().timeIntervalSince1970 - timeCreation < 28800 // 8 hours in seconds
    }

    /// TODO: remove this
    public func printFields() {
        NSLog("username = \(self.username)")
        NSLog("password = \(self.password)")
        NSLog("time creation = \(String(self.timeCreation))")
        NSLog("pubcookie_g = \(self.pubcookie_g)")
        NSLog("pubcookie_l = \(self.pubcookie_l)")
        NSLog("pubcookie_g_req = \(self.pubcookie_g_req)")
    }

    /// Step 1
    /// Invokes a GET request to weblogin service to retrieve first kiss cookies and is used for logging in
    /// Typically used with getLogin()
    ///
    /// - Parameters:
    ///   - completion: Returns a dictionary of first kiss cookies
    public func webLoginFirstKiss(completion: @escaping (() -> Void) ) {

        var firstKiss: [String: String] = [:]

        // Requesting
//        let requestFirstKiss =
            Alamofire.request("https://weblogin.washington.edu/", method: .get)
            .response { response in

            guard response.data != nil else {
                NSLog("got nothing from firstKiss")
                return
            }

            let data = response.data
            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // Parsing
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    firstKiss.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                firstKiss.updateValue(self.username, forKey: "user")
                firstKiss.updateValue(self.password, forKey: "pass")
                
                self.firstKiss = firstKiss
                completion()

            } catch Exception.Error(let type, let message) {
                NSLog("!!!firstKiss failed!!! type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }
        }
    }

    /// Step 2
    /// Invokes a POST request to login and retrieves cookies
    ///
    /// - Parameters:
    ///   - cookies: First kiss cookies, typically from getFirstKiss()
    ///   - completion: returns nothing
    public func weblogin(cookies: [String: String], completion: @escaping () -> Void) {

        // Requesting
        let requestLogin = Alamofire.request("https://weblogin.washington.edu/", method: .post, parameters: cookies)
        requestLogin.validate()
        requestLogin.responseJSON { response in

            guard response.data != nil else {
                NSLog("got nothing from weblogin")
                return
            }

            // Setting cookies
            self.pubcookie_l = String((response.response!.allHeaderFields["Set-Cookie"] as! String).split(separator: ";")[0])
            completion()
        }
    }

    /// Step 3
    /// Getting a course page and cookies accordingly, redirect to weblogin
    ///
    /// - Parameters:
    ///   - url: url, e.g. https://www.washington.edu/cec/f/FHL333A4651.html
    ///   - completion: returns nothing
    public func getCoursePage(_ url: String, completion: @escaping (() -> Void)) {

        var cookies: [String: String] = [:]

        // Requesting
        guard url.isValidURL else { NSLog("Bad URL"); return }
        let requestCoursePage = Alamofire.request(url)
        requestCoursePage.validate()
        requestCoursePage.response { response in

            guard response.data != nil else {
                NSLog("got nothing \(response.error.debugDescription)")
                return
            }

            let data = response.data

            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)
                
//                NSLog("*****************")
//                NSLog(try doc.text())
//                NSLog("*****************")

                // Parsing
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    cookies.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                // Setting cookies
                let a = "pubcookie_g_req=" + (cookies["pubcookie_g_req"] ?? "NOT FOUND")
                let b = "relay_url=" + (cookies["relay_url"] ?? "NOT FOUND")
                self.pubcookie_g_req = a + "&" + b

                completion()

            } catch Exception.Error(let type, let message) {
                NSLog("!!!getCoursePage failed!!! type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }
        }
    }


    /// Step 4
    /// The "You do not have Javascript turned on" page. Gets pubcookie_g
    ///
    /// - Parameter
    ///   - completion: returns nothing
    public func webloginRedirect(_ url: String, completion: @escaping (() -> Void)) {

        var cookies: [String: String] = [:]
        let params: [String: String] =
                ["Cookie": self.pubcookie_l,
                 "Referer": url]

        // Requesting
        let requestLogin = Alamofire.request("https://weblogin.washington.edu",
                method: .post,
                parameters: params,
                encoding: self.pubcookie_g_req,
                headers: [:])
        requestLogin.validate()
        requestLogin.response { response in

            guard response.data != nil else {
                NSLog("got nothing from webloginRedirect")
                return
            }

            let data = response.data
            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // Parsing
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    cookies.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                // Setting cookies
                self.pubcookie_g = "pubcookie_g=" + (cookies["pubcookie_g"] ?? "NOT FOUND")
                self.redirect_url = cookies["redirect_url"] ?? "NOT FOUND"

                completion()

            } catch Exception.Error(let type, let message) {
                NSLog("!!!webloginRedirect failed!!! type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }
        }
    }

    /// Step 5
    /// Gets course page
    ///
    /// - Parameters:
    ///   - url: Course URL
    ///   - completion: returns nothing
    public func getCoursePageWithCookie(_ url: String, completion: @escaping ((Document) -> Void)) {

        let params: [String: String] =
                ["Referer": "https://weblogin.washington.edu/"]

        guard url.isValidURL else { NSLog("Bad URL"); return }

        // Requesting
        let requestCoursePage =
                Alamofire.request(url, method: .get,
                        parameters: params,
                        headers: ["Cookie": self.pubcookie_g])
        requestCoursePage.validate()
        requestCoursePage.response { response in

            guard response.data != nil else {
                NSLog("got nothing from getCoursePageWithCookie")
                return
            }

            let data = response.data
            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)
                completion(doc)

            } catch Exception.Error(let type, let message) {
                NSLog("!!!getCoursePageWithCookie failed!!! type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }
        }
    }

    public func getStats(_ url: String) -> [String: Any] {

        guard let _ = URL(string: url) else {
            NSLog("Bad URL")
            return [:]
        }

        return ["Quarter": "WI18",
                "Statistics": ["Instructor\'s contribution:": ["46%", "35%", "18%", "2%", "0%", "0%", "4.38"],
                               "The course as a whole:": ["47%", "37%", "14%", "2%", "0%", "0%", "4.43"],
                               "Instructor\'s effectiveness:": ["54%", "25%", "18%", "2%", "2%", "0%", "4.57"],
                               "Instructor\'s interest:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
                               "Amount learned:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
                               "Grading techniques:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
                               "The course content:": ["44%", "44%", "12%", "0%", "0%", "0%", "4.36"]],
                "Surveyed": "\"58\"",
                "Enrolled": "\"147\"",
                "Name": "Joel Ross"]
    }
}
