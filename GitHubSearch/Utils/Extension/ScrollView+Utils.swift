//
//  ScrollView+Utils.swift
//  GitHubSearch
//
//  Created by 김지섭 on 2022/01/05.
//

import UIKit

extension UIScrollView {
    var isNeedMoreLoad: Bool {
         guard self.frame.height < self.contentSize.height else { return false }
        let endPosition = self.contentOffset.y + self.frame.height
        let targetY = self.contentSize.height * 0.8
        return endPosition > targetY
    }
}
