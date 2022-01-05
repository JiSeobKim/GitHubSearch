//
//  SearchRepositoryMock.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation
import RxSwift
import RxRelay

final class SearchRepositoryMock: SearchRepository {
    var perPage: Int = 30
    var onNetworking: PublishSubject<Bool> = .init()
    var errorMessage: PublishSubject<String> = .init()
    var result: BehaviorRelay<RepositoryListInfo> = .init(value: .emptyResult)
    
    var isSuccessTest = true
    
    var fetchCallCount = 0
    func fetch(keyword: String, page: Int) {
        fetchCallCount += 1
        onNetworking.onNext(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.onNetworking.onNext(false)
            switch self.isSuccessTest {
            case true:
                let data = self.dummyLoader()
                self.result.accept(data)
                
            case false:
                self.errorMessage.onNext("Error")
            }
        }
    }
    
    private func dummyLoader() -> RepositoryListInfo {
        guard
            let data = DummyJsonLoader.load(api: .searchJSON),
            let convertedValue = try? JSONDecoder().decode(RepositoryInfo.self, from: data)
        else { return .emptyResult }
        
        let list: [RepositoryInfo] = .init(repeating: convertedValue, count: perPage)
        let listInfo = RepositoryListInfo(
            totalCount: perPage,
            incompleteResults: false,
            repoList: list
        )
        
        return listInfo
    }
}
