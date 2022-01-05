//
//  SearchViewController.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/03.
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchViewEventListner {
    func updateKeyword(_ keyword: String)
    func loadMore()
    func clear()
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Plz Insert".localized
        return controller
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.backgroundColor = .systemGray3
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        activity.frame.size = .init(width: 70, height: 70)
        activity.layer.cornerRadius = 8
        return activity
    }()
    
    var viewModel: SearchViewModel?
    private let cellID = "cell"
    private var bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.subscribe()
    }
}

extension SearchViewController {
    private func setUI() {
        self.title = "GitHub Search".localized
        self.navigationItem.searchController = searchController
        self.view.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            activityIndicatorView.widthAnchor.constraint(equalToConstant: activityIndicatorView.frame.width),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: activityIndicatorView.frame.height)
        ])
    }
    
    private func subscribe() {
        searchController.searchBar.rx
            .text
            .orEmpty
            .filter{$0 != ""}
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] keyword in
                self?.viewModel?.updateKeyword(keyword)
            }).disposed(by: bag)
        
        viewModel?.tableReload
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                self?.tableView.reloadData()
            }).disposed(by: bag)
        
        viewModel?.tableInsert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] indexes in
                self?.tableView.insertRows(at: indexes, with: .fade)
            }).disposed(by: bag)
        
        viewModel?.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] isLoading in
                self?.toogleIndicator(isShow: isLoading)
            }).disposed(by: bag)
        
        viewModel?.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] message in
                self?.showErrorAlert(message: message)
            }).disposed(by: bag)
    }
    
    private func showErrorAlert(message: String) {
        let controller = UIAlertController(
            title: message,
            message: nil,
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(
            title: "retry".localized,
            style: .default,
            handler: { _ in
                guard
                    let keyword = self.searchController.searchBar.searchTextField.text
                else { return }
                self.viewModel?.updateKeyword(keyword)
            })
        
        
        let cancelAction = UIAlertAction(
            title: "cancel".localized,
            style: .default,
            handler: nil
        )
        
        controller.addAction(cancelAction)
        controller.addAction(retryAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func toogleIndicator(isShow: Bool) {
        switch isShow {
        case true:
            self.activityIndicatorView.startAnimating()
            UIView.animate(withDuration: 0.7) {
                self.activityIndicatorView.alpha = 1
            }
            
        case false:
            
            UIView.animate(withDuration: 0.7) {
                self.activityIndicatorView.alpha = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.repoList.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        guard
            let cCell = cell as? SearchTableViewCell,
            let viewModel = self.viewModel?.repoList[safe: indexPath.row]
        else { return cell }
        
        cCell.setViewModel(viewModel)
        
        return cCell
    }
}

