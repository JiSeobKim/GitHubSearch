//
//  SearchTableViewCell.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/04.
//

import UIKit
import Kingfisher

class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repositoryLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var watchersCountLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.avatarImageView.layer.cornerRadius = 4
        self.avatarImageView.layer.borderColor = UIColor.systemGray2.cgColor
        self.avatarImageView.layer.borderWidth = 1
    }

    func setViewModel(_ viewModel: SearchTableViewModel) {
        avatarImageView.kf.setImage(
            with: viewModel.avataImgURL,
            options: [.transition(.fade(0.3))]
        )
        userNameLabel.text = viewModel.userName
        repositoryLabel.text = viewModel.repositoryName
        descriptionLabel.text = viewModel.description
        watchersCountLabel.text = viewModel.watchersCount
//        languageLabel.text = viewModel
    }

}
