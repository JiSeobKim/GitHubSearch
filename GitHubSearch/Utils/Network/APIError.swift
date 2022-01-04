//
//  APIError.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/03.
//

enum APIError: Error {
    case networkFail
    case convertingFail
    
    var localized: String {
        switch self {
        case .networkFail:
            return "Fail network"
        case .convertingFail:
            return "Fail response converting"
        }
    }
}
