//
//  MaxIntWrapper.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation

@propertyWrapper
struct LimitedMaxIntWrapper {
    private var max: Int
    private var value = 0
    
    init(maxValue: Int) {
        max = maxValue
    }
    
    var wrappedValue: Int {
        get { return value }
        set { value = min(newValue, max)}
    }
}
