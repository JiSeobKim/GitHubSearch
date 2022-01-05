//
//  SearchBuilder.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation
import UIKit

struct SearchBuilder {
    let viewModel: SearchViewModel
    let viewController: SearchViewController
    
    private let repository: SearchRepository
    private let interactor: SearchInteractor
    
    init() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyBoard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        repository = SearchRepositoryImp()
        interactor = SearchInteractorImp(repository: repository)
        viewModel = SearchViewModelImp(interactor: interactor)
        
        viewController.viewModel = viewModel
    }
}
