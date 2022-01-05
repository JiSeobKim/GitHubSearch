//
//  LocalJsonLoader.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation

final class DummyJsonLoader {
    enum API: String {
        case searchJSON = "SearchJSON"
    }
    
    
    static func load(api: API) -> Data? {
        let extensionType = "json"

        let resource: String = api.rawValue
        
        guard let fileLocation = Bundle.main.url(forResource: resource, withExtension: extensionType) else { return nil }
        
        
        do {
            let data = try Data(contentsOf: fileLocation)
            return data
        } catch {
            return nil
        }
    }
    
    static func load<T: Decodable> (api: API, type: T.Type) -> T? {
        
        guard let data = load(api: api) else { return nil }
        
        do {
            let decodeData = try JSONDecoder().decode(type, from: data)
            return decodeData
        } catch let e {
            print("fail load dummy: \(e)")
            return nil
        }
        
    }
}

