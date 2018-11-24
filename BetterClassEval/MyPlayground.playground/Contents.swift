import Foundation
import SwiftSoup
import JavaScriptCore
//import WebKit
//import UIKit
//import PlaygroundSupport



// ///////////
// Create UIWebView
// ///////////
//print("0")
//let target = URL(string: "https://www.washington.edu/")!
//print("1")
//let request = URLRequest(url: target)
//let view: WKWebView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1200))
//view.load(request)
//print("2")
//
//public let container = UIView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1200))
//print("3")
//container.addSubview(view)
//print("4")
//PlaygroundPage.current.liveView = container
//print("5")
//PlaygroundPage.current.needsIndefiniteExecution = true
//
//print("wut")

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// ///////////
// Fields
// ///////////
let url: String = "http://localhost:8000/"
var raw_data: Data? = nil
var txt_data: String = ""
var result_data: String = ""

// ///////////
// Gets class urls and codes
// ///////////
let get_all_class = URLSession.shared.dataTask(with: URL(string: url + "letter.html")!) { (data, response, error) in
    
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
        
        for e: Element in hrefs {
            let href: String = try e.attr("href")
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
            
            print(href, dept, number_code, section)
            
        }
        
    } catch Exception.Error(let type, let message) {
        print("type: \(type), message: \(message)")
    } catch {
        print("error")
    }

}

get_all_class.resume()

// ///////////
// Gets stats
// ///////////
let get_class = URLSession.shared.dataTask(with: URL(string: url + "data.html")!) { (data, response, error) in
    
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

get_class.resume()

