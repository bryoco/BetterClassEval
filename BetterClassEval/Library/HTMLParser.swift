//
//  HTMLParser.swift
//  BetterClassEval
//
//  Created by Rico Wang on 11/26/18.
//  Copyright © 2018 Group_5. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

//// MARK: - Utility extension for formatting
//extension String {
//    func condenseWhitespace() -> String {
//        let components = self.components(separatedBy: .whitespacesAndNewlines)
//        return components.filter { !$0.isEmpty }.joined(separator: " ")
//    }
//}

public class HTMLParser {

    /// Parses and returns all classes from a given "toc" webpage
    /// e.g. https://www.washington.edu/cec/X-toc.html
    ///
    /// - Parameters:
    ///   - url: An "toc" URL
    ///   - completion: An array of dictionaries of all classes in the provided webpage
    ///
    /// - Usage:
    ///   - call:       HTMLParser().getStats("http://localhost:80/example.html", completion: { result in NSLog(result) })
    ///   - format:     ["link": href, "dept": dept, "number_code": number_code, "section": section]
    func getAllClasses(_ url: String, completion: @escaping (([[String : String]]) -> Void)) {

        let urlStub: String = "https://www.washington.edu/cec/"
        var result: [[String: String]] = []

//        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
        Alamofire.request(url, method: .get)
                .validate()
                .response { response in

                    guard let data = response.data else {
                        NSLog("got nothing from getAllClasses")
                        return
                    }

                    do {

                        let doc: Document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
                        
                        // removes first 9 and last 3 embedded links
                        let hrefs = Array(try doc.select("a").array().dropFirst(9).dropLast(3))

                        for e: Element in hrefs {
//                            NSLog(e.debugDescription)
                            
                            
                            let href: String = try urlStub + e.attr("href")
//                            let href: String = try e.attr("href")
                            
                            let code = Array(String(href.split(separator: "/")[4].split(separator: ".")[0]))

                            // Gets the metadata of class codes
                            var i = 0

                            var dept: String = ""
                            while code[i] >= "A" && code[i] <= "Z" {
                                dept.append(code[i])
                                i += 1
                            }

                            var number_code: String = ""
                            for j in i...i + 2 {
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

                        completion(result)

                    } catch Exception.Error(let type, let message) {
                        NSLog("!!!firstKiss failed!!! type: \(type), message: \(message)")
                    } catch {
                        NSLog("Unspecified error")
                    }
                }
    }

    func parseAllClassHrefs(_ doc: Document) -> [[String : String]] {


        let urlStub: String = "https://www.washington.edu/cec/"
        var result: [[String : String]] = []

        do {

            // removes first 9 and last 3 embedded links
            let hrefs = Array(try doc.select("a").array().dropFirst(9).dropLast(3))

            for e: Element in hrefs {

                // Download data may have two versions
//                let href: String = try urlStub + e.attr("href")
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

                let data: [String: String] = ["link": href, "dept": dept, "number_code": number_code, "section": section]
                result.append(data)
            }

        } catch Exception.Error(let type, let message) {
            NSLog("type: \(type), message: \(message)")
        } catch {
            NSLog("Unspecified error")
        }

        return(result)
    }

/// Parses and returns the statistics of a class from a given "class" webpage
/// e.g. https://www.washington.edu/cec/m/MARINT370A1061.html
///
/// - Parameters:
///   - url: A class URL
///   - completion: A dictionary of statistics of a classes
///
/// - Usage:
///   - call:       HTMLParser().getStats("http://localhost:80/example.html", completion: { result in NSLog(result) })
///   - format:     ["Surveyed": surveyed, "Enrolled": enrolled, "Name": name, "Quarter": quarter, "Statistics": parsed_scores]
///   - example:    ["Quarter": "WI18",
///                  "Statistics": ["Instructor\'s contribution:": ["46%", "35%", "18%", "2%", "0%", "0%", "4.38"],
///                                 "The course as a whole:": ["47%", "37%", "14%", "2%", "0%", "0%", "4.43"],
///                                 "Instructor\'s effectiveness:": ["54%", "25%", "18%", "2%", "2%", "0%", "4.57"],
///                                 "Instructor\'s interest:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
///                                 "Amount learned:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
///                                 "Grading techniques:": ["0%", "0%", "0%", "0%", "0%", "0%", "0.00"],
///                                 "The course content:": ["44%", "44%", "12%", "0%", "0%", "0%", "4.36"]],
///                  "Surveyed": "\"58\"",
///                  "Enrolled": "\"147\"",
///                  "Name": "Joel Ross"]
    func getStatsFromURL(_ url: String, completion: @escaping (([String : Any]) -> Void)) {

        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in

            guard let data = data else {
                NSLog("got error \(error.debugDescription)")
                return
            }

            do {
                let doc: Document = try SwiftSoup.parse(String(data: data, encoding: .utf8)!)
                self.getStatsFromPage(doc, completion: {result in completion(result)})
            } catch Exception.Error(let type, let message) {
                NSLog("type: \(type), message: \(message)")
            } catch {
                NSLog("Unspecified error")
            }}.resume()
    }

    public func getStatsFromPage(_ doc: Document, completion: @escaping (([String : Any]) -> Void)) {

        do {

            // h2 tag, gets lecturer's name and quarter of the class
            let h2: [String] = try doc.select("h2").text().components(separatedBy: " ")
            let name: String = h2[0...1].joined(separator: " ")
            let quarter: String = String(h2[h2.count - 1])

            // caption, gets statistics of the survey
            let caption: String = try doc.select("caption").text().condenseWhitespace()
            let caption_split: [Substring] = caption.split(separator: " ")
            let surveyed: String = String(caption_split[caption_split.index(caption_split.endIndex, offsetBy: -4)])
            let enrolled: String = String(caption_split[caption_split.index(caption_split.endIndex, offsetBy: -2)])

            // tables, gets stats
            let rawStats = try doc.select("td").array()
            var parsedStats = [String:[String]]()
            let NUMBER_OF_ELEMENTS = 8

            for i in stride(from: 0, to: rawStats.count - 1, by: NUMBER_OF_ELEMENTS) {
                var stats: [String] = []
                // only getting data from certain number of tags
                for j in i+1...i+7 { stats.append(try rawStats[j].text()) }
                parsedStats.updateValue(stats, forKey: try rawStats[i].text())
            }

            // final results to return
            let result: [String: Any] = ["Surveyed": surveyed,
                                         "Enrolled": enrolled,
                                         "Name": name,
                                         "Quarter": quarter,
                                         "Statistics": parsedStats]

            completion(result)

        } catch Exception.Error(let type, let message) {
            NSLog("type: \(type), message: \(message)")
        } catch {
            NSLog("Unspecified error")
        }
    }

    public func getStats(_ url: String) -> [String : Any] {

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
