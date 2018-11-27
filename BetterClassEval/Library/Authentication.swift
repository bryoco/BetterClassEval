//
//  Authentication.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/26/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import SwiftSoup
import Alamofire

/// Invokes a GET request to weblogin service to retrieve first kiss cookies and is used for logging in
/// Typically used with getLogin()
///
/// - Parameters:
///   - username: UW NetID
///   - password: Password associated with the NetID
///   - completion: Returns a dictionary of first kiss cookies
///
/// - Usage:
///   - getFirstKiss(username: "", password: "", completion: { result in print(result) })
func getFirstKiss(username: String, password: String, completion: @escaping ((Any) -> Void)) {
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
            
            cookies.updateValue(username, forKey: "user")
            cookies.updateValue(password, forKey: "pass")
            
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
///   - completion: returns raw cookies
func getLogin(cookies: [String : String], completion: @escaping ((Any) -> Void)) {
    
    let requestLogin = Alamofire.request("https://weblogin.washington.edu/", method: .post, parameters: cookies)
    requestLogin.validate()
    requestLogin.response { response in
        
        guard response.data != nil else {
            print("got nothing \(response.error.debugDescription)")
            return
        }
        
        completion(response.response as Any)
        
    }
}
