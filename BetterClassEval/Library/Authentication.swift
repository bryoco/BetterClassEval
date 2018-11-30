//
//  HTMLParser.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/26/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import SwiftSoup
import Alamofire

extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.endIndex.encodedOffset)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.endIndex.encodedOffset
        } else {
            return false
        }
    }

}

/// Entire login process
//user.getFirstKiss(completion: { result in
//    user.getWeblogin(cookies: result, completion: {
//        user.getCoursePage(url, completion: { result in
//            user.getRedirectURL(completion: {
//                user.getCoursePageWithCookie(url, completion: {
//                    print("done")
//                })})})})})
public class Authentication {

    let username: String
    let password: String
    let timeCreation = NSDate().timeIntervalSince1970 // Cookies last for 8 hours

    var pubcookie_g: String
    var pubcookie_g_req: String
    var pubcookie_l: String
    var redirect_url: String
    var uwauth: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password

        self.pubcookie_g = ""
        self.pubcookie_l = ""
        self.pubcookie_g_req = ""
        self.redirect_url = ""
        self.uwauth = ""
    }

    public func ifCookiesValid() -> Bool {
        return NSDate().timeIntervalSince1970 - timeCreation < 28800 // 8 hours in seconds
    }

    /// TODO: remove this
    public func printFields() {
        print(self.username)
        print(self.password)
        print(String(self.timeCreation))
        print(self.pubcookie_g)
        print(self.pubcookie_l)
        print(self.pubcookie_g_req)
        print(self.uwauth)

    }

    /// Invokes a GET request to weblogin service to retrieve first kiss cookies and is used for logging in
    /// Typically used with getLogin()
    ///
    /// - Parameters:
    ///   - completion: Returns a dictionary of first kiss cookies
    ///
    public func firstKiss(completion: @escaping (([String : String]) -> Void)) {
        var cookies: [String : String] = [:]

        // Requesting first kiss cookies
        let requestFirstKiss = Alamofire.request("https://weblogin.washington.edu/", method: .put)
        requestFirstKiss.validate()
        requestFirstKiss.response { response in

            guard response.data != nil else {
                print("got nothing \(response.error.debugDescription)")
                return
            }

            let data = response.data

            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // Getting first kiss data
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    cookies.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                cookies.updateValue(self.username, forKey: "user")
                cookies.updateValue(self.password, forKey: "pass")

                completion(cookies)

            } catch Exception.Error(let type, let message) {
                print("type: \(type), message: \(message)")
            } catch {
                print("Unspecified error")
            }
        }
    }

    // TODO: Isolate and only return "Set-Cookie" field
    /// Invokes a POST request to login and retrieves cookies
    ///
    /// - Parameters:
    ///   - cookies: First kiss cookies, typically from getFirstKiss()
    ///   - completion: returns nothing
    public func weblogin(cookies: [String : String], completion: @escaping () -> Void) {

        let requestLogin = Alamofire.request("https://weblogin.washington.edu/", method: .post, parameters: cookies)
        requestLogin.validate()
        requestLogin.responseJSON { response in

            guard response.data != nil else {
                print("got nothing \(response.error.debugDescription)")
                return
            }

            self.pubcookie_l = String((response.response!.allHeaderFields["Set-Cookie"] as! String).split(separator: ";")[0])

            completion()
        }
    }

    /// Getting a course page and cookies accordingly, redirect to weblogin
    ///
    /// - Parameters:
    ///   - url: url
    ///   - completion: returns nothing
    public func getCoursePage(_ url: String, completion: @escaping (() -> Void)) {

        var cookies: [String : String] = [:]

        // https://www.washington.edu/cec/f/FHL333A4651.html
        guard url.isValidURL else {
            NSLog("Bad URL")
            return
        }

        let requestCoursePage = Alamofire.request(url)
        requestCoursePage.validate()
        requestCoursePage.response { response in

            guard response.data != nil else {
                print("got nothing \(response.error.debugDescription)")
                return
            }

            let data = response.data

            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // Getting first cookies
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    cookies.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                // Getting two more cookies from this page
                let a = "pubcookie_g_req=" + (cookies["pubcookie_g_req"] ?? "NOT FOUND")
                let b = "relay_url=" + (cookies["relay_url"] ?? "NOT FOUND")
                self.pubcookie_g_req = a + "&" + b

                completion()

            } catch Exception.Error(let type, let message) {
                print("type: \(type), message: \(message)")
            } catch {
                print("Unspecified error")
            }
        }
    }


    /// The "You do not have Javascript turned on" page. Gets pubcookie_g
    ///
    /// - Parameter
    ///   - completion: returns nothing
    public func webloginRedirect(_ url: String , completion: @escaping (() -> Void)) {

        var cookies: [String : String] = [:]

        let params: [String : String] =
                ["Cookie": self.pubcookie_l,
                 "Referer": url]

        let requestLogin = Alamofire.request("https://weblogin.washington.edu",
                method: .post,
                parameters: params,
                encoding: self.pubcookie_g_req,
                headers: [:])
        requestLogin.validate()
        requestLogin.response { response in

            guard response.data != nil else {
                NSLog("got nothing \(response.error.debugDescription)")
                return
            }

            let data = response.data

            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // Getting first kiss data
                let elements = try doc.select("[type=hidden]")
                for e in elements {
                    cookies.updateValue(try e.val(), forKey: try e.attr("name"))
                }

                self.pubcookie_g = "pubcookie_g=" + (cookies["pubcookie_g"] ?? "NOT FOUND")
                self.redirect_url = cookies["redirect_url"] ?? "NOT FOUND"

                completion()

            } catch Exception.Error(let type, let message) {
                NSLog("type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }
        }
    }

    /// Gets course page
    ///
    /// - Parameters:
    ///   - url: Course URL
    ///   - completion: returns nothing
    public func getCoursePageWithCookie(_ url: String, completion: @escaping (() -> Void)) {

        let params: [String : String] =
                ["Referer":"https://weblogin.washington.edu/"]

        guard url.isValidURL else {
            NSLog("Bad URL")
            return
        }

        let requestCoursePage =
                Alamofire.request(url, method: .get,
                        parameters: params,
                        headers: ["Cookie":self.pubcookie_g])
        requestCoursePage.validate()
        requestCoursePage.response { response in

            guard response.data != nil else {
                print("got nothing \(response.error.debugDescription)")
                return
            }

            let data = response.data

            do {

                let doc: Document = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)

                // TODO
                print(try doc.text())


            } catch Exception.Error(let type, let message) {
                print("type: \(type), message: \(message)")
            } catch {
                print("Unspecified error")
            }
        }
    }
}
