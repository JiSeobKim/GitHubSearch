//
//  Array+Utils.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/05.
//

import Foundation


extension Array {
    subscript(safe index: Int) -> Element? {
        guard self.indices ~= index else { return nil }
        return self[index]
    }
}
