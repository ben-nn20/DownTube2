//
//  YoutubeAPIFormatter.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/7/21.
//

import Foundation
import SwiftSoup
import JavaScriptCore

extension String: Identifiable {
    public var id: String {
        self
    }
    mutating func replaceOccurances(of: String, with: String) {
        self = self.replacingOccurrences(of: of, with: with, options: .literal, range: nil)
    }
    mutating func removePercentEncoding() {
        replaceOccurances(of: "%20", with: " ")
        replaceOccurances(of: "%21", with: "!")
        replaceOccurances(of: "%22", with: "\"")
        replaceOccurances(of: "%23", with: "#")
        replaceOccurances(of: "%24", with: "$")
        replaceOccurances(of: "%25", with: "%")
        replaceOccurances(of: "%26", with: "&")
        replaceOccurances(of: "%27", with: "'")
        replaceOccurances(of: "%28", with: "(")
        replaceOccurances(of: "%29", with: ")")
        replaceOccurances(of: "%2A", with: "*")
        replaceOccurances(of: "%2B", with: "+")
        replaceOccurances(of: "%2C", with: ",")
        replaceOccurances(of: "%2D", with: "-")
        replaceOccurances(of: "%2E", with: ".")
        replaceOccurances(of: "%2F", with: "/")
        replaceOccurances(of: "%30", with: "0")
        replaceOccurances(of: "%31", with: "1")
        replaceOccurances(of: "%32", with: "2")
        replaceOccurances(of: "%33", with: "3")
        replaceOccurances(of: "%34", with: "4")
        replaceOccurances(of: "%35", with: "5")
        replaceOccurances(of: "%36", with: "6")
        replaceOccurances(of: "%37", with: "7")
        replaceOccurances(of: "%38", with: "8")
        replaceOccurances(of: "%39", with: "9")
        replaceOccurances(of: "%3A", with: ":")
        replaceOccurances(of: "%3B", with: ";")
        replaceOccurances(of: "%3C", with: "<")
        replaceOccurances(of: "%3D", with: "=")
        replaceOccurances(of: "%3E", with: ">")
        replaceOccurances(of: "%3F", with: "?")
        replaceOccurances(of: "%40", with: "@")
        replaceOccurances(of: "%7A", with: "z")
        replaceOccurances(of: "%7B", with: "{")
        replaceOccurances(of: "%7C", with: "|")
        replaceOccurances(of: "%7D", with: "}")
        replaceOccurances(of: "%7E", with: "~")
        replaceOccurances(of: "%5B", with: "[")
        replaceOccurances(of: "%5C", with: "\\")
        replaceOccurances(of: "%5D", with: "]")
        replaceOccurances(of: "%5E", with: "^")
        replaceOccurances(of: "%5F", with: "_")
    }
}
extension Array {
    mutating func appended(_ value: Element) -> Self {
        self.append(value)
        return self
    }
}
struct YoutubeAPIParser {
    private var videoId: String
    init(_ videoId: String) {
        self.videoId = videoId
    }
    mutating func format(_ completionHandler: @escaping (VideoInfo?) -> Void) {
        let req = URLRequest(url: URL(string: "https://www.youtube.com/watch?v=\(videoId)")!)
        URLSession.shared.dataTask(with: req) { (data, response, error) in
            guard error == nil else {
                logs.insert(error!, at: 0)
                return
            }
            logs.insert(NSError(domain: "Retreiving Youtube Info", code: 0, userInfo: nil), at: 0)
            do {
            let doc = try SwiftSoup.parse(String(data: data!, encoding: .utf8)!)
            logs.insert(NSError(domain: "Parsed html.", code: 0, userInfo: nil), at: 0)
            guard let script = try doc.getElementsByTag("script").first(where: { element in
                let text = String(describing: element)
                return text.contains("ytInitialPlayerResponse") && text.contains("\"responseContext\"")
            }) else {
                return
            }
            
            var js = script.data()
            js.removePercentEncoding()
            let context = JSContext()
            let str = context!.evaluateScript(js + "JSON.stringify(ytInitialPlayerResponse, null, null);").toString()!
            let jsonDecoder = JSONDecoder()
            do {
                let youtubeInfo = try jsonDecoder.decode(VideoInfo.self, from: str.data(using: .utf8)!)
                completionHandler(youtubeInfo)
            } catch {
                logs.insert(error, at: 0)
                print(error)
                }
            } catch {
                logs.insert(error, at: 0)
                print(error)
            }
        }.resume()
    }
}
