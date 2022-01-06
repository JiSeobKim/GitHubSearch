//
//  SearchTableViewModel.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import Foundation

struct SearchTableViewModel {
    var userName: String?
    var repositoryName: String?
    var description: String?
    var watchersCount: String?
    var avataImgURL: URL?
    var language: String?
    var isHiddenLauguageStack: Bool
    
    init(_ repoInfo: RepositoryInfo) {
        self.userName = repoInfo.owner.login
        self.repositoryName = repoInfo.name
        self.description = repoInfo.description
        self.watchersCount = repoInfo.watchers.decimalStyle
        self.language = repoInfo.language
        self.isHiddenLauguageStack = repoInfo.language == nil
        
        if let avatarURL = repoInfo.owner.avatarURL {
            self.avataImgURL = URL(string: avatarURL)
        }
    }
}
