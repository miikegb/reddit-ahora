//
//  Introspection.swift
//  RedditClientTests
//
//  Created by Miguel Gonzalez on 4/5/24.
//

import Foundation

func deepDescription(of value: Any) -> String {
    var desc = ""
    func recursiveDesc(of value: Any, description: inout String, tabs: Int = 0) {
        let mirror = Mirror(reflecting: value)
        let tabsString = String(repeating: "\t", count: tabs)
        for child in mirror.children {
            let labelString = if child.label != nil { "\(child.label!):" } else { "" }
            switch type(of: child.value) {
            case is String.Type, is Int.Type, is Float.Type, is Bool.Type:
                description += "\(tabsString)\(labelString) \(child.value)\n"
            default:
                description += "\(tabsString)\(child.label ?? ""):\n"
                recursiveDesc(of: child.value, description: &description, tabs:  tabs + 1)
            }
        }
    }
    recursiveDesc(of: value, description: &desc)
    return desc.trimmingCharacters(in: .whitespacesAndNewlines)
}
