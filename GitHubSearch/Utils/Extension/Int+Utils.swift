//
//  Int+Utils.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation

extension Int {
    var decimalStyle: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let decimalStrig = formatter.string(from: NSNumber(value: self))
        
        return decimalStrig ?? "0"
    }
}
