//
//  SearchRepository.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import RxRelay
import RxSwift

protocol SearchRepository {
    var perPage: Int { get set }
    var onNetworking: PublishSubject<Bool> { get }
    var errorMessage: PublishSubject<String> { get }
    var result: PublishSubject<RepositoryListInfo> { get }
    
    func fetch(keyword: String, page: Int)
}


class SearchRepositoryImp: SearchRepository {
    @LimitedMaxIntWrapper(maxValue: 100, value: 30)
    var perPage: Int
    var onNetworking: PublishSubject<Bool> = .init()
    var errorMessage: PublishSubject<String> = .init()
    var result: PublishSubject<RepositoryListInfo> = .init()
    
    
    func fetch(keyword: String, page: Int) {
        onNetworking.onNext(true)
        
        let api = GitHubAPI.searchRepo(keyword: keyword, page: page, perPage: perPage)
        
        api.request(requestType: RepositoryListInfo.self) { [weak self] result in
            self?.onNetworking.onNext(false)
            
            switch result {
            case .success(let data):
                self?.result.onNext(data)
            case .failure(let error):
                self?.errorMessage.onNext(error.localized)
            }
        }
    }
}
