//
//  HTMLParser.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/26/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import SwiftSoup
import JavaScriptCore
import WebKit
import UIKit

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

/// Gets all classes from a given "toc" webpage
/// i.e. https://www.washington.edu/cec/X-toc.html
///
/// - Parameter url: <#url description#>
func getAllClass(_ url: String) {
    
    var raw_data: Data? = nil
    var txt_data: String = ""
    let url_stub: String = "https://www.washington.edu/cec/"
    var result: [Any] = []
    
    let get_all_class = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
        
        guard let data = data else {
            print("got error \(error.debugDescription)")
            return
        }
        
        raw_data = data
        txt_data = String(data: raw_data!, encoding: .utf8)!
        
        do {
            
            let doc: Document = try SwiftSoup.parse(txt_data)
            
            // removes first 9 and last 3 embedded links
            let hrefs = Array(try doc.select("a").array().dropFirst(9).dropLast(3))
            
            print("start")
            
            for e: Element in hrefs {
                let href: String = try url_stub + e.attr("href")
                let code = Array(String(href.split(separator: "/")[4].split(separator: ".")[0]))
                
                // Gets the metadata of class codes
                var i = 0
                
                var dept: String = ""
                while code[i] >= "A" && code[i] <= "Z" {
                    dept.append(code[i])
                    i += 1
                }
                
                var number_code: String = ""
                for j in i...i+2 {
                    number_code.append(code[j])
                }
                
                // The loop above does not move i forward, moving manually
                i += 3
                var section: String = ""
                while code[i] >= "A" && code[i] <= "Z" {
                    section.append(code[i])
                    i += 1
                }
                
                let data: [String: String] = ["link": href, "dept": dept, "number_code": number_code, "section": section]
                result.append(data)
                
            }
            
        } catch Exception.Error(let type, let message) {
            print("type: \(type), message: \(message)")
        } catch {
            print("error")
        }
        
    }
    
    get_all_class.resume()
//    return result
}

// ///////////
// Gets stats of a class
// ///////////
func getStats(_ url: String) {
    
    var raw_data: Data? = nil
    var txt_data: String = ""
    
    let get_stats = URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
        
        guard let data = data else {
            print("got error \(error.debugDescription)")
            return
        }
        
        raw_data = data
        txt_data = String(data: raw_data!, encoding: .utf8)!
        
        do {
            
            let doc: Document = try SwiftSoup.parse(txt_data)
            
            //
            
            // h2 tag, gets lecturer's name and quarter of the class
            let h2: String = try doc.select("h2").text()
            let name: String = h2.split(separator: " ")[0...1].joined(separator: " ")
            let quarter: String = String(h2.split(separator: " ")[3])
            
            // caption, gets statistics of the survey
            let caption: String = try doc.select("caption").text().condenseWhitespace()
            let caption_split = caption.split(separator: " ")
            let surveyed: String = String(caption_split[caption_split.index(caption_split.endIndex, offsetBy: -4)])
            let enrolled: String = String(caption_split[caption_split.index(caption_split.endIndex, offsetBy: -2)])
            
            // tables, gets stats
            let meta_scores = try doc.select("td").array()
            let NUMBER_OF_ELEMENTS = 8
            var parsed_scores = [String:[String]]()
            
            for i in stride(from: 0, to: meta_scores.count - 1, by: NUMBER_OF_ELEMENTS) {
                var stats: [String] = []
                for j in i+1...i+7 { stats.append(try meta_scores[j].text()) }
                parsed_scores.updateValue(stats, forKey: try meta_scores[i].text())
            }
            
            // final results to return
            let result: [String: Any] = ["Surveryed": surveyed,
                                         "Enrolled": enrolled,
                                         "Name": name,
                                         "Quarter": quarter,
                                         "Statistics": parsed_scores]
            
            print(result)
            
        } catch Exception.Error(let type, let message) {
            print("type: \(type), message: \(message)")
        } catch {
            print("error")
        }
    }
    
    get_stats.resume()
}
