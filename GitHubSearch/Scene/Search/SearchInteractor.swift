//
//  SearchInteractor.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import RxRelay
import RxSwift
import Foundation

protocol SearchInteractor {
    var keyword: String? { get set }
    var result: BehaviorRelay<RepositoryListInfo> { get }
    var onNetworking: PublishSubject<Bool> { get }
    var errorMessage: PublishSubject<String> { get }
    
    var tableReload: PublishSubject<Void> { get }
    var tableInsert: PublishSubject<[IndexPath]> { get }
    
    func clear()
    func fetch()
}

class SearchInteractorImp: SearchInteractor {

    var keyword: String? {
        didSet {
            self.itemCount = 0
        }
    }
    
    var result: BehaviorRelay<RepositoryListInfo> { repository.result }
    var onNetworking: PublishSubject<Bool> { repository.onNetworking }
    var errorMessage: PublishSubject<String> { repository.errorMessage }

    var tableReload: PublishSubject<Void>
    var tableInsert: PublishSubject<[IndexPath]>
    
    private let repository: SearchRepository
    private var bag: DisposeBag
    private var repoPage: Int { itemCount / repository.perPage }
    private var itemCount: Int
    
    init(repository: SearchRepository) {
        self.repository = repository
        self.tableReload = .init()
        self.tableInsert = .init()
        self.itemCount = 0
        self.bag = DisposeBag()
        self.subscribe()
    }
    
    func fetch() {
        guard let keyword = keyword else { return }
        repository.fetch(keyword: keyword, page: repoPage)
    }
    
    func clear() {
        self.keyword = nil
        self.itemCount = 0
        let empty = RepositoryListInfo.emptyResult
        self.repository.result.accept(empty)
    }
    
    private func subscribe() {
        repository.result
            .subscribe(onNext: { [weak self] data in
                self?.updateRepoInfos(list: data.repoList)
            }).disposed(by: bag)
    }
    
    private func updateRepoInfos(list: [RepositoryInfo]) {
        switch self.repoPage == 0 {
        case true:
            // First
            self.tableReload.onNext(())
            self.itemCount = list.count
            
        case false:
            // Load More
            let start = self.itemCount
            let end = start + list.count
            
            let newIndexes = (start..<end).map{IndexPath(row: $0, section: 0)}
            self.tableInsert.onNext(newIndexes)
            self.itemCount += list.count
        }
    }
}
