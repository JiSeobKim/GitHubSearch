//
//  GitHubAPI.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/03.
//

import Alamofire
import Foundation

enum GitHubAPI {
    case searchRepo(keyword: String, page: Int, perPage: Int)
    
    var domain: String {
      return "https://api.github.com/"
    }
    
    var url: String {
        var url = domain + path
        
        if let qParam = queryParameters {
            url += "?\(qParam)"
        }
        
        return url
    }
    
    var method: HTTPMethod {
        switch self {
        case .searchRepo:
            return .get
        }
    }
    
    var headers: HTTPHeaders {
        let header: HTTPHeaders = [
            .accept("application/vnd.github.v3+json")
        ]
        return header
    }
    
    var path: String {
        switch self {
        case .searchRepo:
            
            return "search/repositories"
        }
    }
    
    var queryParameters: String? {
        switch self {
        case .searchRepo(param: let param):
            let new = param.keyword.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
            return "q=\(new)&page=\(param.page)&per_page=\(param.perPage)"
        }
    }
    
    var bodyParameter: [String:Any]? {
        switch self {
        case .searchRepo:
            return nil
        }
    }
    
    func request<T: Decodable>(requestType:T.Type, complete: @escaping ((Result<T,APIError>)->())) {
        
        let request = AF.request(
            url,
            method: method,
            parameters: bodyParameter,
            encoding: JSONEncoding.default,
            headers: headers
        )
        
        request.responseData() { response in
            do {
                let data = response.data
                let convertedValue = try JSONDecoder().decode(T.self, from: data!)
                complete(.success(convertedValue))
            } catch {
                print(error)
                complete(.failure(.convertingFail))
            }
            
//            guard
//                let data = response.data,
//                let convertedValue = try? JSONDecoder().decode(T.self, from: data)
//            else {
//                complete(.failure(.convertingFail))
//                return
//            }
//            complete(.success(convertedValue))
        }
    }
}
