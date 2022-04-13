//
//  SelfSizedTableView.swift
//  UIKit-MVVM-RxSwift
//
//  Created by Vlad Shmatok on 12.04.2022.
//

import UIKit

class SelfSizedTableView: UITableView {

    // MARK: - Properties

    var maxHeight: CGFloat = .infinity

    // MARK: - Lifecycle

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
}
