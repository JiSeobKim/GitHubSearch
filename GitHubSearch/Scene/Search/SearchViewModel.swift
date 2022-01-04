//
//  SearchViewModel.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import RxRelay
import RxSwift
import Foundation

protocol SearchViewModel: SearchViewEventListner {
    var repoList: [SearchTableViewModel] { get }
    var tableReload: PublishSubject<Void> { get }
    var tableInsert: PublishSubject<[IndexPath]> { get }
    var isLoading: PublishSubject<Bool> { get }
    var showMessage: PublishSubject<String> { get }
}


class SearchViewModelImp: SearchViewModel {
    
    var repoList: [SearchTableViewModel]
    
    var tableReload: PublishSubject<Void> { interactor.tableReload }
    var tableInsert: PublishSubject<[IndexPath]> { interactor.tableInsert }
    
    var isLoading: PublishSubject<Bool> { interactor.onNetworking }
    var showMessage: PublishSubject<String> { interactor.errorMessage }
    
    private var interactor: SearchInteractor
    private var bag: DisposeBag
    
    init(interactor: SearchInteractor) {
        self.repoList = []
        self.interactor = interactor
        self.bag = DisposeBag()
        self.subscribe()
    }
    
    func updateKeyword(_ keyword: String) {
        interactor.keyword = keyword
        interactor.fetch()
    } 
    
    func loadMore() {
        interactor.fetch()
    }
    
    func clear() {
        self.repoList = []
        interactor.clear()
    }
    
    
    private func subscribe() {
        interactor.result
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                let new = result.repoList.map{SearchTableViewModel($0)}
                self.repoList += new
            }).disposed(by: bag)
    }
}
