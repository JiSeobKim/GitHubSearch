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
    @IBOutlet weak var noResultLabel: UILabel!
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Plz Insert".localized
        return controller
    }()
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.backgroundColor = .lightGray
        activity.style = .large
        activity.color = .white
        activity.hidesWhenStopped = true
        activity.stopAnimating()
        activity.frame.size = .init(width: 90, height: 90)
        activity.layer.cornerRadius = 12
        activity.layer.cornerCurve = .continuous
        return activity
    }()
    
    var viewModel: SearchViewModel?
    private let cellID = "cell"
    private var bag = DisposeBag()
    private var isEmpty: Bool {
        return viewModel?.repoList.count == 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.subscribe()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.tableView.contentInset == .zero {
            self.tableView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
}

extension SearchViewController {
    private func setUI() {
        self.title = "GitHub Search".localized
        self.navigationItem.searchController = searchController
        self.view.addSubview(activityIndicatorView)
        self.noResultLabel.text = "Empty Result".localized
        
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
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] keyword in
                self?.viewModel?.updateKeyword(keyword)
            }).disposed(by: bag)
        
        viewModel?.tableReload
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.toogleNoResultLabel(isShow: self.isEmpty)
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
    
    private func toogleNoResultLabel(isShow: Bool) {
        noResultLabel.isHidden = !isShow
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isNeedMoreLoad {
            viewModel?.loadMore()
        }
    }
}

