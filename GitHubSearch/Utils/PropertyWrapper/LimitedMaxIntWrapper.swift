//
//  LimitedMaxIntWrapper.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation

@propertyWrapper
struct LimitedMaxIntWrapper {
    private var max: Int
    private var value: Int
    
    init(maxValue: Int, value: Int) {
        self.max = maxValue
        self.value = value
    }
    
    var wrappedValue: Int {
        get { return value }
        set { value = min(newValue, max)}
    }
}
