//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/03.
//

import UIKit


protocol SearchViewEventListner {
    func updateKeyword(_ keyword: String)
    func loadMore()
    func clear()
}

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

