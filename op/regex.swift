//
//  regex.swift
//  op
//
//  Created by Home on 12/6/2022.
//

import Foundation

// https://stackoverflow.com/questions/27880650/swift-extract-regex-matches/56616990#56616990
extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
